# HeadChecker - 낚시성 뉴스 기사 판별기

헤드라인과 본문의 정보를 토대로 낚시성 뉴스 기사인지 판별하는 모델을 학습시켜 모바일로 서비스하는 프로젝트입니다.



## Data

사용한 데이터셋: AIhub-낚시성 기사 탐지 데이터 ([낚시성 기사 탐지 데이터](https://aihub.or.kr/aihubdata/data/view.do?currMenu=115&topMenu=100&aihubDataSe=realm&dataSetSn=71338))

데이터 전처리:
```
# 대괄호, 소괄호 안의 내용 삭제, 따옴표 삭제

def preprocess_sentence(sentence):
    sentence = re.sub(r'\([^)]*\)', '', sentence) # 괄호로 닫힌 문자열 (...) 제거 
    sentence = re.sub(r'\[[^]]*\]', '', sentence) # [] 닫힌 문자열 제거
    sentence = re.sub(r'\\"','', sentence) # 쌍따옴표 \" 제거
    sentence = re.sub(r'\'', '', sentence) # 따옴표 ' 제거
    return sentence

# 너무 긴 기사의 경우 학습에 방해가 될 것으로 판단하여 1200자 이상의 기사 삭제

over_content_idx = df[df['cleanContLength'] > threshold_content].index
df2 = df.drop(over_content_idx)

```

## Model

Bert 기반의 모델을 사용하여 SequenceClassification Task로 파인 튜닝
* 서비스에 적용한 모델
    * 'klue/bert-base' 체크포인트
    * pretrain: 한국어 더미 뉴스 데이터와 낚시성 기사 탐지 데이터로 MLM 학습
    * fine-tuning: 낚시성 기사 탐지 데이터  
    (하이퍼파라미터:  
    MAX_LEN = 512  
    batch_size = 16  
    learning_rate = 2e-5  
    scheduler = linear)

## Train

pytorch lightning을 활용한 학습 코드 개발

### requirements

lightning == 2.0.9  
torch == 2.0.1  
torchmetrics == 1.1.2  
transformers == 4.33.1  

### training

```
python train.py -m 'MODEL_NAME' -t 'path/train/data.csv' -v 'path/test/data.csv' -ml max_length -bs batch_size -fc bool
```

## Service

1. flutter를 활용해 모바일 어플리케이션과 크롬 익스텐션 서비스 개발  
2. FastAPI 활용해 백엔드 서버 구현

자세한 내용은 service 폴더 readme 참고