import re
import torch
import tensorflow
import transformers
import numpy as np
from transformers import BertTokenizer, BertForSequenceClassification, AdamW, BertConfig
from tensorflow import keras
from inference import test_sentences
import uvicorn
from fastapi import FastAPI, HTTPException
from typing import List, Optional
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

USER_AGENT = "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36"

origins = ["*"] 

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["GET", "PUT", "PATCH", "POST", "DELETE"],
    allow_headers=["Origin", "X-Requested-With", "Content-Type", "Accept"],
)

class NewsItem(BaseModel):
    title: str
    link: str
    img: str
    time: str

class UrlRequest(BaseModel):
    link: str

def get_soup(url):
    headers = {"User-Agent": USER_AGENT}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "lxml")
    return soup

def scrape_news_list(url, limit=4):
    soup = get_soup(url)
    newslist = soup.select(".section_list_ranking_press")
    newsData = []

    for news in newslist[:limit]:
        lis = news.find_all("li")
        for li in lis:
            list_title = li.select_one(".list_tit")
            news_title = list_title.text
            news_link = list_title.get("href")
            try:
                news_img = li.select_one("img")["src"]
            except:
                news_img = None
            news_time = ""

            newsData.append(
                {
                    "title": news_title,
                    "link": news_link,
                    "img": news_img,
                    "time": news_time,
                }
            )

    return newsData

def scrape_news_details(newsData):
    for news in newsData:
        news_url = news["link"]
        soup = get_soup(news_url)
        news_time = soup.select_one(".media_end_head_info_datestamp .media_end_head_info_datestamp_time")["data-date-time"]
        news["time"] = news_time

def clean_text(text):
    cleaned_text = re.sub(r'\s+|[^\w\s]', ' ', text)
    return cleaned_text

@app.get("/news", response_model=List[NewsItem])
def get_news(limit: Optional[int] = 4):
    url = "https://news.naver.com/main/main.naver?mode=LSD&mid=shm&sid1=105"
    newsData = scrape_news_list(url, limit)
    scrape_news_details(newsData)
    return newsData

@app.post("/inference")
async def inference(request: UrlRequest):
    link = request.link

    response = requests.get(link)

    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        title = soup.title.string if soup.title else "No title found"
        content = soup.get_text()

        cleaned_content = clean_text(content)

        inference = test_sentences(title, cleaned_content)
        inference = str(inference[0][1])

        result = {"title": title, "inference": inference}
        return result
    else:
        return {"error": "Failed to fetch URL"}

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
