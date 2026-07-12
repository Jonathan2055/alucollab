# ALUCollab

ALUCollab is a Flutter application for managing student talent, startups, and admin workflows inside the ALU ecosystem. The app connects alu startups that are looking for interns or employees and alu students who are interested to participate and make some impact and the app uses Firebase  authenticate users and store user profiles, opportunities, startups, and notifications.

## Project Highlights

- Role-based experience for:
  - **Students** — browse and apply for opportunities, view and customize your own profile and view notifications and application.
  - **Startup owners** — upload opportunities, manage venture listings, track verification status, and view applicant metrics.
  - **Admins** — verify startups, moderate content and manage users.
- app is built with:
  - `flutter`
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`
  - `provider`
- Theme support for dark mode and light mode across the app
- Firebase-powered authentication and role-based routing

## Repo Clone

```bash
git clone https://github.com/Jonathan2055/alucollab.git
cd alucollab
```

## things you should already have installed before using app

- Flutter SDK installed
- A configured Firebase project with Firestore and Authentication
- `flutter` available in your terminal

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Configure Firebase

The project includes `lib/firebase_options.dart`, but if you are using a different Firebase project, generate your own configuration file using the FlutterFire CLI or Firebase console.

If you want to reconfigure manually:

```bash
flutterfire configure
```


## Run the App

```bash
flutter run 
```


## How to Use ALUCollab

### 1. Launch and authentication

- The app starts on the welcome screen.
- Use **Get Started** to register as a Student or Startup.
- Use **I am already a member** to navigate to the login screen.
- Sign in with email and password.

### 2. Role-based routing

The app automatically routes users based on their role stored in Firestore:

- `student` = **Student dashboard**
- `startupOwner` = **Startup dashboard**
- `admin` = **Admin dashboard**

### 3. Student experience

- Browse active opportunities and search by keyword/category.
- View recommended listings.
- Open opportunity details and apply.
- Follow their application status.
- Access student profile update there infos on *Account Details*, view notification on notification center, and toggle theme according to their liking.

### 4. Startup owner experience

- View venture dashboard and verification status.
- Create and manage opportunities and applicant metrics.
- Access profile screen for toggling theme according to the liking and signing-out.

### 5. Admin experience

- Review total users, live posts, and pending verifications.
- moderation feed to manage all opportunities, verification queue to verify startups and user management to verify all users.
- Toggle dark/light mode.
- Another thing because an admin created randomly I have a demo data for the admin but if you used different firebase project you have to create a user and asign him as an admin in your database(username:```bash admin@alueducation.com``` and password is ```bash admin123```).

## Firebase Notes

Make sure your Firebase rules allow the app to read and write the required collections. The app currently uses:

- `users`
- `startups`
- `opportunities`
- `notifications`

> If you are getting `permission-denied`, update your Firestore security rules to allow authenticated admin access for user delete operations and authenticated access for reads/writes used by the app.

## Troubleshooting

- If the app fails to connect to Firebase, make sure `lib/firebase_options.dart` is set up for your Firebase project.
- If authentication succeeds but the app does not route correctly, verify the `role` field exists on the Firestore `users/{uid}` document.
- If delete actions fail, confirm Firestore security rules allow the current authenticated user to perform that operation.

## Project Structure

- `lib/main.dart` — app entrypoint and provider setup
- `lib/presentation/screens/auth/` — login, signup, welcome, and auth routing
- `lib/presentation/screens/student/` — student dashboard and profile flow
- `lib/presentation/screens/startup/` — startup owner dashboard and opportunity management
- `lib/presentation/screens/admin/` — admin dashboard, verification, moderation, and user management
- `lib/data/repositories/` — Firebase repository code for auth, notifications, startups, and opportunities
- `lib/providers/` — app-level state providers for auth, theme, and opportunities
- `lib/core/constants/` — app color theming and UI helpers
