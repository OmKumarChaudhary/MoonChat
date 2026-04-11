from flask import Flask
from flask_cors import CORS
from routes.crypto import crypto_bp
from routes.chatbot_route import chatbot_bp
from routes.admin_route import admin_bp
import firebase_admin

# Initialize Firebase Admin SDK
try:
    # Requires either GOOGLE_APPLICATION_CREDENTIALS environment variable 
    # or deployed on GCP/Firebase to automatically find credentials.
    firebase_admin.initialize_app()
    print("Firebase Admin SDK initialized successfully.")
except Exception as e:
    print(f"Failed to initialize Firebase Admin SDK. {e}")

# Initialize Flask application
app = Flask(__name__)

# Enable Cross-Origin Resource Sharing (CORS) for all routes
# This is crucial for allowing the Flutter app (running on a different port/origin) to communicate with this backend
CORS(app)

# Register blueprints for modular routing
# All crypto-related routes will be prefixed with /api/crypto
app.register_blueprint(crypto_bp, url_prefix='/api/crypto')

# All chatbot-related routes will be prefixed with /api/chatbot
app.register_blueprint(chatbot_bp, url_prefix='/api/chatbot')

# Admin routes
app.register_blueprint(admin_bp, url_prefix='/api/admin')

@app.route('/')
def home():
    """Default route to check if the server is running."""
    return "MoonChat Backend is Running!"

if __name__ == '__main__':
    # Start the Flask development server
    # '0.0.0.0' makes the server accessible from other devices in the same network
    app.run(host='0.0.0.0', port=5000, debug=True)
