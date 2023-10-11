import numpy as np
import pandas as pd
import random
import torch
import os
import argparse
from transformers import AutoTokenizer, AutoConfig, AutoModelForSequenceClassification

import lightning.pytorch as pl
import torchmetrics

from lightning.pytorch.callbacks import EarlyStopping, ModelCheckpoint
from lightning.pytorch.loggers import WandbLogger

from model3 import Model
from load_data2 import get_dataloader


def seed_everything(seed):
    os.environ["PYTHONHASHSEED"] = str(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
    np.random.seed(seed)
    random.seed(seed)
    
def main(MODEL_NAME, TRAIN_PATH, TEST_PATH, MAX_LEN, BATCH_SIZE, LR, TRAIN_FC_ONLY):
    seed_everything(42)
    os.environ["TOKENIZERS_PARALLELISM"] = "false"
    
    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
    train_dataloader, valid_dataloader, test_dataloader = get_dataloader(TRAIN_PATH, TEST_PATH, tokenizer, MAX_LEN, BATCH_SIZE)
    total_steps = len(train_dataloader) * 20

    model = Model(MODEL_NAME, total_steps, lr=LR, train_only_fc=TRAIN_FC_ONLY)
    ckpt_dir = 'model/ckpt'
    ckpt_filename = MODEL_NAME + '-{epoch}-{valid_loss}'
    
    wandb_logger = WandbLogger(project="mahimahi")
    
    early_stop_callback = EarlyStopping(
        monitor='valid_loss',
        patience=5,
        verbose=True,
        mode='min'
    )

    model_checkpoint = ModelCheckpoint(
        dirpath=ckpt_dir,
        filename=ckpt_filename,
        save_top_k = 1,
        monitor='valid_loss',
        mode='min'
    )
    
    callbacks = [early_stop_callback, model_checkpoint]
    
    trainer = pl.Trainer(logger=wandb_logger,
                     check_val_every_n_epoch=1,
                     callbacks = callbacks,
                     max_epochs=20)
    
    trainer.fit(model, train_dataloader, valid_dataloader)
    
    trainer.test(ckpt_path="best", dataloaders=test_dataloader)
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--model", dest="MODEL_NAME", action="store")
    parser.add_argument("-t", dest="TRAIN_PATH", action="store")
    parser.add_argument("-v", dest="TEST_PATH", action="store")
    parser.add_argument("-ml", dest="MAX_LEN", action='store')
    parser.add_argument("-bs", dest="BATCH_SIZE", action='store')
    parser.add_argument("-lr", dest="Learning_Rate", action='store')
    parser.add_argument("-fc", dest="TRAIN_FC_ONLY", action='store')
    
    
    args = parser.parse_args()
    TRAIN_FC_ONLY = (args.TRAIN_FC_ONLY.lower() == 'true')
    if args.Learning_Rate:
        LR = float(args.Learning_Rate)
    else:
        LR = 2e-5
    
    main(args.MODEL_NAME, args.TRAIN_PATH, args.TEST_PATH, int(args.MAX_LEN), int(args.BATCH_SIZE), LR, TRAIN_FC_ONLY)
    






