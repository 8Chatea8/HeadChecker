import numpy as np
import pandas as pd
import random
import torch
import wandb
from transformers import AutoTokenizer, AutoConfig, AutoModelForSequenceClassification, get_linear_schedule_with_warmup

import lightning.pytorch as pl
from lightning.pytorch.callbacks import EarlyStopping, ModelCheckpoint
from lightning.pytorch.loggers import WandbLogger
import torchmetrics

from load_data2 import get_dataloader



class Model(pl.LightningModule):

    def __init__(self, MODEL_NAME, total_steps, lr=2e-5, train_only_fc=False):
        super(Model, self).__init__()
        model_config = AutoConfig.from_pretrained(MODEL_NAME)
        model_config.num_labels = 2
        model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME, config=model_config,
                                                                  ignore_mismatched_sizes=True)

        self.total_steps = total_steps
        self.lr = lr
        
        if train_only_fc:
            for param in model.parameters():
                param.requires_grad = False
            for param in model.classifier.parameters():
                param.requires_grad = True

        self.model = model
            
        self.accuracy = torchmetrics.classification.BinaryAccuracy()
        self.precision = torchmetrics.classification.BinaryPrecision()

    def forward(self, x):
        input_ids = x['input_ids']
        attention_mask = x['attention_mask']
        token_type_ids = x['token_type_ids']

        return self.model(input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids)
        

    def configure_optimizers(self):
        optimizer = torch.optim.AdamW(
                self.model.parameters(),
                lr=self.lr,
                betas=(0.9, 0.999),
                eps=1e-08,
                )

        scheduler = get_linear_schedule_with_warmup(
            optimizer,
            num_warmup_steps = 0,
            num_training_steps = self.total_steps)
        
        return dict(
            optimizer = optimizer,
            lr_scheduler = dict(scheduler=scheduler, interval='step')
        )

    def _shared_step(self, batch, batch_idx):
        labels = batch["label"]
        input_ids = batch["input_ids"]
        attention_mask = batch["attention_mask"]
        token_type_ids = batch["token_type_ids"]

        output = self.model(
                input_ids,
                token_type_ids=token_type_ids,
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
