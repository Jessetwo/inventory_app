#Flutter Inventory Management App

A simple yet powerful Inventory Management System built with Flutter.
This app allows users to add, edit, view, and delete products, including details such as product name, price, quantity, category, description, and image.
It’s lightweight, offline-first, and perfect for small businesses or personal stock management.

🚀 Features

✅ Add New Product — Capture essential details including name, category, description, price, and quantity.

🖼️ Image Support — Pick product images from your device’s gallery.

✏️ Edit Products — Easily update product information.

❌ Delete Products — Remove items with confirmation dialogs.

💾 Local Database (SQLite) — Offline data storage using sqflite.

🧭 Modern UI — Simple, intuitive, and responsive Flutter interface.

🔐 Permission Handling — Requests necessary permissions to access files securely.

🛠️ Tech Stack
Technology	   Purpose
Flutter    	   Frontend framework
Dart	       Programming Language
SQLite (sqflite)	Local database
File Picker / Image Picker	Image selection from device
Permission Handler	Runtime permission management




    

⚙️ Setup Instructions

Follow these steps to get started locally 👇

1️⃣ Clone the Repository
git clone https://github.com/<your-username>/flutter-inventory-app.git
cd flutter-inventory-app

2️⃣ Install Dependencies
flutter pub get

3️⃣ Run the App
flutter run

🔒 Permissions

Make sure you have the following permissions in your AndroidManifest.xml:

<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />


And ensure the permission_handler package is properly configured in your app.

🧱 Packages Used
Package	Description
sqflite	SQLite database for local data storage
path_provider	Helps access app storage directories
permission_handler	Requests runtime permissions
image_picker	Picks images from device gallery

📦 Example Product Data
Field	  Example
Name	  Nike Air Max
Category	Shoes
Price	  25000
Quantity	15
Description	 Lightweight running shoe
Image	   Picked from gallery


Apk link: https://appetize.io/app/b_64b2dkfus5vtxd7aongvwzlk34
Demo-video link: https://drive.google.com/file/d/1qNpUHbFzEEmHkeEYFA7hgc6i1BTbL1r0/view?usp=sharing

🧑‍💻 Author

Jesse Kanadi
💼 UI/UX Designer & Flutter Developer
📧 jessekanadi@gmail.com
