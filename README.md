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

📸 _Screenshot Placeholder_  
`![Authentication](screenshots/authentication.png)`

---

### 🧺 Ingredient Management

Track and manage your ingredients easily:

- Add, update, and delete ingredients
- Track inventories
- Monitor quantities

📸 _Screenshot Placeholder_  
`![Ingredients List](screenshots/ingredients_list.png)`

---

### 🔍 Smart Recipe Recommendations

Find recipes based on what you already have:

- Personalized recipe suggestions based on your stock
- Cook using what's already in your kitchen
- View recipe instructions and required ingredients

📸 _Screenshot Placeholder_  
`![Recipe Suggestions](screenshots/recipe_suggestions.png)`

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
- Utilized ingredients stock stored in Firebase Firestore to find recipe recommendations based on available ingredients
