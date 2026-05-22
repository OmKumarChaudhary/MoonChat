# 🛡️ Privacy Policy for MoonChat

**Effective Date:** May 22, 2026  
**Last Updated:** May 22, 2026  

Welcome to **MoonChat** ("we," "our," or "us"). MoonChat is a modern, AI-powered social and financial application designed for the crypto community, available for Android devices (Package Name: `com.omkumar.moonchat`). We are committed to protecting your privacy and ensuring you have a secure experience when using our app.

This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and backend services. Please read this policy carefully. If you do not agree with the terms of this privacy policy, please do not access or use the application.

---

## 📋 Table of Contents
1. [Information We Collect](#1-information-we-collect)
2. [How We Use Your Information](#2-how-we-use-your-information)
3. [Third-Party Services & APIs](#3-third-party-services--apis)
4. [Data Storage & Security](#4-data-storage--security)
5. [Data Retention & Account Deletion](#5-data-retention--account-deletion)
6. [Children's Privacy](#6-childrens-privacy)
7. [Your Rights (GDPR / CCPA)](#7-your-rights-gdpr--ccpa)
8. [Changes to This Privacy Policy](#8-changes-to-this-privacy-policy)
9. [Contact Us](#9-contact-us)

---

## 1. Information We Collect

To provide a fully-featured, personalized experience (such as custom profiles, real-time messaging, and an interactive AI chatbot), we collect several types of data.

### A. Personal Data You Provide Directly
* **Account Credentials:** When you sign up or log in, we collect your email address and password (via Firebase Authentication) or your Google Account details (via Google Sign-In).
* **Profile Information:** To customize your public profile, we collect details you choose to enter, including:
  * Display Name
  * Profile Biography (Bio)
  * Gender
  * Date of Birth
  * Profile Picture (uploaded via the app using your device's camera or photo library)
* **Chat Content:** We collect and store the text messages and shared media (images) you exchange with other users in the real-time chat interface to deliver and display them as intended.

### B. Device & Permissions Data
To run the app correctly on Android, we request the following permissions:
* **Internet Permission (`android.permission.INTERNET`):** Used to connect to our Firebase backend, fetch real-time cryptocurrency data, communicate with the AI chatbot, and send messages.
* **Notification Permission (`android.permission.POST_NOTIFICATIONS`):** Used to send you push notifications about new messages, community updates, or system alerts (if active).
* **Media & Storage Access:** When uploading a profile picture or sharing an image in chat, the app uses system intents to pick media files from your photo library or use the camera.

### C. Automatically Collected Data
* **Log & Usage Data:** We automatically log crash details, app performance diagnostics, and general usage statistics (e.g., button clicks, navigation flows) using Firebase services to debug and improve app stability.
* **Push Tokens:** Unique device identifiers needed to route push notifications through Firebase Cloud Messaging (FCM).

---

## 2. How We Use Your Information

We use the collected information for the following specific purposes:
* **To Provide real-time messaging:** Storing and routing chat messages between you and other users.
* **To Maintain Your Account:** Authenticating your identity, persisting sessions across devices, and handling password recovery.
* **To Personalize Profiles:** Displaying your name, bio, and profile picture to other users within the MoonChat community.
* **To Power the AI Assistant:** Sending messages you send to the AI chatbot to our backend Flask server (hosted on Hugging Face Spaces) to process and return helpful answers.
* **To Deliver Real-time Crypto Data:** Requesting market information based on the tokens you search for.
* **To Improve & Maintain the App:** Analyzing crash logs and performance metadata to fix bugs and improve performance.

---

## 3. Third-Party Services & APIs

MoonChat integrates with several third-party service providers to power its features. These services have their own privacy policies governing their usage of your data:

| Service / Provider | Purpose | Link to Privacy Policy |
| :--- | :--- | :--- |
| **Firebase (Google)** | Core Backend, Firestore database, Firebase Auth, Firebase Storage, and Push Notifications. | [Firebase Privacy Policy](https://firebase.google.com/support/privacy) |
| **Google Sign-In** | Optional single sign-on mechanism for quick account authentication. | [Google Privacy Policy](https://policies.google.com/privacy) |
| **Hugging Face** | Hosting our standalone Flask backend that handles the AI chatbot's response generation. | [Hugging Face Privacy Policy](https://huggingface.co/privacy) |
| **CoinGecko** | Pulling real-time cryptocurrency price data (no personal user data is sent to CoinGecko). | [CoinGecko Privacy Policy](https://www.coingecko.com/en/privacy) |

---

## 4. Data Storage & Security

We take the security of your personal data seriously. 
* All user authentication data, profile information, and chat content is stored in **Google Firebase (Firestore and Storage)**, benefiting from Google's enterprise-grade infrastructure security.
* Data transmitted between the app, Firebase, and our Hugging Face backend is encrypted in transit using **HTTPS / TLS protocols**.
* While we implement standard security measures, please note that no method of transmission over the internet or method of electronic storage is 100% secure, and we cannot guarantee absolute data security.

---

## 5. Data Retention & Account Deletion

### A. Data Retention
We retain your personal information (profile data, authentication credentials, chat history) for as long as your account remains active. 

### B. Account & Data Deletion (Google Play Compliance)
Google Play requires that users can easily request the deletion of their account and all associated data. We make this simple:
* **In-App Option:** You can navigate to **Settings > Account > Delete Account** within the MoonChat application to initiate an automated erasure of your profile.
* **Via Email Request:** If you cannot access the app or wish to request deletion manually, you can email us at: **omkumar.wd@gmail.com**.
* **What is Deleted:** Upon account deletion request, your authentication profile, custom details (display name, bio, gender, DOB), profile pictures, and sent chat messages will be permanently deleted from our active database (Firebase Auth, Cloud Firestore, and Firebase Storage) within **30 days**.

---

## 6. Children's Privacy

MoonChat does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. If we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us at `omkumar.wd@gmail.com` so we can take the necessary actions.

---

## 7. Your Rights (GDPR / CCPA)

Depending on your geographical location (e.g., if you are residing in the European Union or California), you may have the following rights regarding your data:
* **Right to Access:** You can request copies of your personal data stored on our servers.
* **Right to Rectification:** You can edit your profile details directly in the app at any time, or request corrections.
* **Right to Erasure:** You can delete your account, erasing your data from our systems (as outlined in [Section 5](#5-data-retention--account-deletion)).
* **Right to Restrict Processing:** You can request that we restrict the processing of your personal data.

To exercise any of these rights, please contact us using the details below.

---

## 8. Changes to This Privacy Policy

We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date at the top of this document. You are advised to review this Privacy Policy periodically for any changes.

---

## 9. Contact Us

If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us:

* **Email:** [omkumar.wd@gmail.com](mailto:omkumar.wd@gmail.com)
* **GitHub Repository:** [OmKumarChaudhary/MoonChat](https://github.com/OmKumarChaudhary/MoonChat)

