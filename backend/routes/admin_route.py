from flask import Blueprint, request, jsonify
import firebase_admin
from firebase_admin import auth, messaging, firestore

admin_bp = Blueprint('admin_bp', __name__)

# User Management routes
@admin_bp.route('/users', methods=['GET'])
def get_users():
    """List all users (Admin only)"""
    try:
        page = auth.list_users()
        users = []
        for user in page.users:
            users.append({
                'uid': user.uid,
                'email': user.email,
                'display_name': user.display_name,
                'disabled': user.disabled,
                'creation_time': user.user_metadata.creation_timestamp,
                'last_sign_in_time': user.user_metadata.last_sign_in_timestamp
            })
        return jsonify({'status': 'success', 'users': users}), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@admin_bp.route('/users/<uid>/status', methods=['POST'])
def update_user_status(uid):
    """Enable or Disable a user"""
    try:
        data = request.json
        disabled = data.get('disabled', False)
        auth.update_user(uid, disabled=disabled)
        return jsonify({'status': 'success', 'message': f'User {uid} status updated to disabled={disabled}'}), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@admin_bp.route('/users/<uid>', methods=['DELETE'])
def delete_user(uid):
    """Delete a user permanently"""
    try:
        auth.delete_user(uid)
        return jsonify({'status': 'success', 'message': f'User {uid} deleted'}), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

# Push Notifications routes
@admin_bp.route('/push', methods=['POST'])
def send_push():
    """Send Firebase Cloud Messaging (FCM) push notification"""
    try:
        data = request.json
        title = data.get('title')
        body = data.get('body')
        topic = data.get('topic', 'all') # default broadcast topic
        token = data.get('token')

        if token:
            # Send to specific device token
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                token=token,
            )
            response = messaging.send(message)
        else:
            # Send to topic
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                topic=topic,
            )
            response = messaging.send(message)
            
        return jsonify({'status': 'success', 'response': response}), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

# Newsletter routing (Simulated - could hook up to SendGrid/Mailchimp or just email list in Firestore)
@admin_bp.route('/newsletter', methods=['POST'])
def send_newsletter():
    try:
        data = request.json
        subject = data.get('subject')
        content = data.get('content')
        # Logic to send newsletter emails here...
        return jsonify({'status': 'success', 'message': 'Newsletter sending triggered'}), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500
