import numpy as np
import pandas as pd
import torch
from torch.utils.data import Dataset, DataLoader, random_split, RandomSampler, SequentialSampler
from transformers import AutoTokenizer


RANDOM_SEED = 42

class NewsDataset(Dataset):
    def __init__(self, dataset):
        self.labels = dataset['label']
        self.input_ids = dataset['input_ids']
        self.attention_mask = dataset['attention_mask']
        self.totken_type_ids = dataset['token_type_ids']

    def __len__(self):
        return len(self.labels)

    def __getitem__(self, idx):
        label = self.labels[idx]
        input_ids = self.input_ids[idx]
        attention_mask = self.attention_mask[idx]
        token_type_ids = self.totken_type_ids[idx]
        return {"label": label, 
                "input_ids": input_ids, 
                "attention_mask": attention_mask,
                "token_type_ids": token_type_ids,
               }
    

def load_data(trainset_file_path, testset_file_path):
    train_data = pd.read_csv(trainset_file_path, encoding='utf-8')
    test_data = pd.read_csv(testset_file_path, encoding='utf-8')

    if train_data.isnull().sum().sum() != 0:
        train_data = train_data.dropna()
        train_data = train_data.reset_index(drop=True)

    if test_data.isnull().sum().sum() != 0:
        test_data = test_data.dropna()
        test_data = test_data.reset_index(drop=True)
    
    return train_data, test_data

def preprocessing_data(dataset, tokenizer, max_length):
    headline = [sent for sent in dataset['Headline']]
    content = [sent for sent in dataset['Content']]
        
    tokenized_sentences = tokenizer(
        headline, content,
        return_tensors = "pt",
        padding = True,
        truncation = True,
        max_length = max_length,
        add_special_tokens = True,
        return_token_type_ids= True,
    )

    input_ids = tokenized_sentences.input_ids
    attention_mask = tokenized_sentences.attention_mask
    token_type_ids = tokenized_sentences.token_type_ids
    label = torch.tensor(dataset['Class'])
    
    return {
        "label": label,
        "input_ids": input_ids,
        "attention_mask": attention_mask,
        "token_type_ids": token_type_ids,
    }

def get_dataloader(train_path, test_path, tokenizer, MAX_LEN, BATCH_SIZE):
    # 데이터 파일 로드
    train_data, test_data = load_data(train_path, test_path)
    
    # 토크나이징 & 데이터셋 로드
    tokenized_train = NewsDataset(preprocessing_data(train_data, tokenizer, MAX_LEN))
    tokenized_test = NewsDataset(preprocessing_data(test_data, tokenizer, MAX_LEN))
    
    # train, valid split
    generator = torch.Generator().manual_seed(RANDOM_SEED)
    train, valid = random_split(tokenized_train, [0.8, 0.2], generator=generator)
    
    # DataLoader
    train_dataloader = DataLoader(train, sampler=RandomSampler(train), batch_size=BATCH_SIZE, num_workers=8)
    valid_dataloader = DataLoader(valid, sampler=SequentialSampler(valid), batch_size=BATCH_SIZE, num_workers=8)
    test_dataloader = DataLoader(tokenized_test, sampler=SequentialSampler(tokenized_test), batch_size=BATCH_SIZE, num_workers=8)
    
    return train_dataloader, valid_dataloader, test_dataloader

