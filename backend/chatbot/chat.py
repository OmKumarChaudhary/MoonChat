import json
import numpy as np
from tensorflow.keras.models import load_model
import nltk
from nltk.stem import WordNetLemmatizer
import string
import pandas as pd

lemmatizer = WordNetLemmatizer()
model = load_model("marichitechai_model.h5")
words = json.load(open("marichitechai_words.json"))
classes = json.load(open("marichitechai_classes.json"))
df = pd.read_csv('marichitechai_chatbot.csv')


def preprocess(text):
    text = text.lower()
    text = text.translate(str.maketrans('', '', string.punctuation))
    tokens = nltk.word_tokenize(text)
    return [lemmatizer.lemmatize(token) for token in tokens]

def bow(text):
    tokenized = preprocess(text)
    bag = [1 if w in tokenized else 0 for w in words]
    return np.array(bag)

def predict_class(text):
    pred = model.predict(np.array([bow(text)]))[0]
    return classes[np.argmax(pred)]

def get_response(text):
    intent = predict_class(text)
    return df[df['intent']==intent]['answer'].values[0]