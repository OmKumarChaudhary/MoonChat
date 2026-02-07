from flask import Flask
from flask_cors import CORS
from routes.crypto import crypto_bp

# Initialize Flask application
app = Flask(__name__)

# Enable Cross-Origin Resource Sharing (CORS) for all routes
# This is crucial for allowing the Flutter app (running on a different port/origin) to communicate with this backend
CORS(app)

# Register blueprints for modular routing
# All crypto-related routes will be prefixed with /api/crypto
app.register_blueprint(crypto_bp, url_prefix='/api/crypto')

@app.route('/')
def home():
    """Default route to check if the server is running."""
    return "MoonChat Backend is Running!"

if __name__ == '__main__':
    # Start the Flask development server
    # '0.0.0.0' makes the server accessible from other devices in the same network
    app.run(host='0.0.0.0', port=5000, debug=True)
