import json
import numpy as np
import os
import string
import pandas as pd

# Mock/Fallback logic if ML libraries are not fully setup or files missing
HAS_ML = False
try:
    from tensorflow.keras.models import load_model
    import nltk
    from nltk.stem import WordNetLemmatizer
    lemmatizer = WordNetLemmatizer()
    HAS_ML = True
except ImportError:
    print("AI dependencies (tensorflow/nltk) missing. Using fallback mode.")

# Load models with safety checks
model = None
words = []
classes = []
df = None

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def load_resources():
    global model, words, classes, df
    try:
        model_path = os.path.join(BASE_DIR, "..", "marichitechai_model.h5")
        words_path = os.path.join(BASE_DIR, "..", "marichitechai_words.json")
        classes_path = os.path.join(BASE_DIR, "..", "marichitechai_classes.json")
        csv_path = os.path.join(BASE_DIR, "..", "marichitechai_chatbot.csv")

        if HAS_ML and os.path.exists(model_path):
            model = load_model(model_path)
            words = json.load(open(words_path))
            classes = json.load(open(classes_path))
            df = pd.read_csv(csv_path)
            return True
    except Exception as e:
        print(f"Error loading chatbot resources: {e}")
    return False

RESOURCES_LOADED = load_resources()

def preprocess(text):
    text = text.lower()
    text = text.translate(str.maketrans('', '', string.punctuation))
    if HAS_ML:
        import nltk
        tokens = nltk.word_tokenize(text)
        return [lemmatizer.lemmatize(token) for token in tokens]
    return text.split()

def bow(text):
    tokenized = preprocess(text)
    bag = [1 if w in tokenized else 0 for w in words]
    return np.array(bag)

def predict_class(text):
    if not RESOURCES_LOADED or model is None:
        return "fallback"
    pred = model.predict(np.array([bow(text)]))[0]
    return classes[np.argmax(pred)]

def get_response(text):
    if not RESOURCES_LOADED or df is None:
        # Very basic rule-based fallback
        text_lower = text.lower()
        if "hello" in text_lower or "hi" in text_lower:
            return "Hello! I am MoonChat's AI Assistant. How can I help you today?"
        if "price" in text_lower or "crypto" in text_lower:
            return "I can help you track crypto prices! Head over to the 'Crypto Track' tab to see real-time data."
        if "who are you" in text_lower:
            return "I am the MoonChat Bot, here to assist you with the app's features."
        return "I'm still learning! Could you please rephrase that? (Model files are currently offline)"
    
    intent = predict_class(text)
    matches = df[df['intent']==intent]['answer']
    if not matches.empty:
        return matches.values[0]
    return "I'm not sure how to answer that yet."