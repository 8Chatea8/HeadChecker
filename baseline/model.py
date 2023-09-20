import numpy as np
import pandas as pd
import random
import torch
import wandb
from transformers import AutoTokenizer, AutoConfig, AutoModelForSequenceClassification

import lightning.pytorch as pl
from lightning.pytorch.callbacks import EarlyStopping, ModelCheckpoint
from lightning.pytorch.loggers import WandbLogger
import torchmetrics

from load_data import get_dataloader



class Model(pl.LightningModule):

    def __init__(self, MODEL_NAME):
        super(Model, self).__init__()
        model_config = AutoConfig.from_pretrained(MODEL_NAME)
        model_config.num_labels = 2
        model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME, config=model_config)
        self.model = model

        self.accuracy = torchmetrics.classification.BinaryAccuracy()
        self.precision = torchmetrics.classification.BinaryPrecision()
        
    def configure_optimizers(self):
        optimizer = torch.optim.AdamW(
                self.model.parameters(),
                lr=2e-5,
                )
        return optimizer

    def _shared_step(self, batch, batch_idx):
        labels = batch["label"]
        input_ids = batch["input_ids"]
        attention_mask = batch["attention_mask"]

        output = self.model(
                input_ids,
                token_type_ids=None,
                attention_mask=attention_mask,
                labels=labels
                )
        return {'loss':output['loss'], 
                'labels':labels, 
                'logits': output['logits']
                }
        
    def training_step(self, batch, batch_idx):
        output = self._shared_step(batch, batch_idx)

        train_loss = output['loss']
        train_acc = self.accuracy(torch.argmax(output['logits'], dim=1), output['labels'])
        train_precision = self.precision(torch.argmax(output['logits'], dim=1), output['labels'])

        self.log('train_loss', train_loss)
        self.log('train_acc_step', train_acc)
        self.log('train_precision_step', train_precision)

        return output


    def validation_step(self, batch, batch_idx):
        output = self._shared_step(batch, batch_idx)

        valid_loss = output['loss']
        valid_acc = self.accuracy(torch.argmax(output['logits'], dim=1), output['labels'])
        valid_precision = self.precision(torch.argmax(output['logits'], dim=1), output['labels'])

        self.log('valid_loss', valid_loss)
        self.log('valid_acc_step', valid_acc)
        self.log('valid_precision_step', valid_precision)

        return output

    def test_step(self, batch, batch_idx):
        output = self._shared_step(batch, batch_idx)
        
        test_acc = self.accuracy(torch.argmax(output['logits'], dim=1), output['labels'])
        test_precision = self.precision(torch.argmax(output['logits'], dim=1), output['labels'])

        self.log('test_acc_step', test_acc)
        self.log('test_precision_step', test_precision)

        return output