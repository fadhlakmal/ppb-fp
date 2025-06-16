# 🧑‍🍳 Cookoo App

**Cookoo** is a mobile application built with **Flutter** that helps you track your kitchen ingredients, get smart recipe recommendations, and schedule your meals — all in one place.

---

## 👥 Authors

| Nama                       | NRP        | Github                        |
| -------------------------- | ---------- | ----------------------------- |
| Fadhl Akmal Madany         | 5025221028 | https://github.com/fadhlakmal |
| Muhammad Detri Abdul Fikar | 5025221236 | https://github.com/SingSopan  |
| Kevin Nathanael Halim      | 5025211140 | https://github.com/zetsux     |

---

## 📱 Overview

Whether you're an occasional cook or a culinary enthusiast, **Cookoo** simplifies your cooking life by making sure you always know:

- What ingredients you have
- What recipes you can make
- When you plan to cook it

Say goodbye to wasted food and last-minute meal decisions.

---

## 🚀 Features

### 👤 Authentication

Secure access to your personalized Cookoo experience:

- User sign up and login via email & password
- Firebase Authentication integration
- Keeps your ingredients, preferences, and meal plans tied to your account

#### 🔑 Authentication

<img width="398" alt="Authentication Screenshot" src="https://github.com/user-attachments/assets/e8261288-440f-4ed2-a849-c473b8b59d71" />

> Login or create an account for a personalized experience

#### 🧑‍💼 User Profile

<img width="396" alt="User Profile Screenshot" src="https://github.com/user-attachments/assets/7645203f-49e1-42ea-b3b1-bd6b1b195244" />

> View your profile and upload image linked to Firebase Storage

---

### 🧺 Ingredient Management

Track and manage your ingredients easily:

- Add, update, and delete ingredients
- Track inventories
- Monitor quantities

📸 _Screenshot Placeholder_  
![image](https://github.com/user-attachments/assets/54d48235-b655-4ef1-80a3-9ac83f477afb)

![image](https://github.com/user-attachments/assets/c0276597-63c2-42c3-bf25-dd055fc63e69)

![image](https://github.com/user-attachments/assets/f0bea96e-1b01-4079-9df5-dd8a62ef6b98)

![image](https://github.com/user-attachments/assets/f484877c-14a0-4207-b43b-496d49740d67)


---

### 🔍 Recipe Recommendations and Management

Find recipes based on what you already have:

- Personalized recipe suggestions based on your stock
- Cook using what's already in your kitchen
- View, save, and freely edit recipe instructions along with the required ingredients

#### 📚 Recipe Collection

<img width="398" alt="Recipe Collections Screenshot" src="https://github.com/user-attachments/assets/495195da-4575-4e71-a983-dc169918c6f1" />

> View all your saved recipes in a clean, organized format

#### 🧠 Recipe Recommendations by Ingredients in Stock

<img width="397" alt="Recipe Recommendations by Ingredients in Stock Screenshot" src="https://github.com/user-attachments/assets/cd6383c7-51c4-4342-b49a-a320aa8accda" />

> Get recipe suggestions based on your pantry stocks

#### 📖 Recipe Detail View

<img width="396" alt="Recipe Recommendation Detail Screenshot" src="https://github.com/user-attachments/assets/6e3a4161-72ab-4ffd-b1b0-80285f866d07" />

> View detailed recipe instructions along with the ingredients needed and save it into your collection

#### 🛠️ Recipe Management

<img width="395" alt="Recipe Management Screenshot" src="https://github.com/user-attachments/assets/37a27554-63f1-4864-8681-b6f5c4dfe9b5" />

> Edit or delete your saved recipes to suit your cooking style
---

### 🗓️ Meal Scheduling

Plan your meals throughout the week:

- Assign recipes to specific days
- Build a structured weekly meal calendar
- Stay on track with your cooking goals

📸 _Screenshot Placeholder_  
`![Meal Planner](screenshots/meal_planner.png)`

---

## 🛠️ Tech Stack

- **Flutter** – Cross-platform mobile app development framework
- **Dart** – Programming language used to write Flutter apps
- **Firebase Firestore** – Real-time NoSQL cloud database to store user's data
- **Firebase Auth** – Handles user's registration and login securely
- **Firebase Storage** – Stores user-uploaded images (e.g., profile pictures)
- **Awesome Notifications** – Local notification plugin for scheduling meal reminders and alerts
- **http** – For fetching data from external recipe APIs or other web services

---

## 💼 Member's Contribution

### Fadhl Akmal Madany (5025221028)

### Muhammad Detri Abdul Fikar (5025221236)

### Kevin Nathanael Halim (5025211140)

- Implemented CRUD functionality for Recipes (Create, Read, Update, Delete) filtered by the authenticated user using Firebase Auth
- Integrated with [The Meal DB API](https://www.themealdb.com) to fetch diverse recipe recommendations with detailed specifications to be added to recipe collections
- Utilized ingredients stock stored in Firebase Firestore to find recipe recommendations based on user's ingredients in stock
