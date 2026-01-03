# Deployment Guide

This guide covers deploying the Local Music Player Flutter application to various platforms.

## Prerequisites

- Flutter SDK (stable channel)
- Android Studio / Xcode (for mobile platforms)
- Firebase account and project
- Google Cloud account (for Google Sign-In)

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: "Local Music Player"
4. Enable Google Analytics (optional)
5. Create project

### 2. Add Android App

1. In Firebase Console, click "Add App" → Android
2. Register app:
   - Package name: `com.example.local_music_player` (or your package)
   - App nickname: "Local Music Player Android"
   - Debug signing certificate SHA-1 (optional)
3. Download `google-services.json`
4. Place in `android/app/google-services.json`
5. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 3. Add iOS App

1. In Firebase Console, click "Add App" → iOS
2. Register app:
   - Bundle ID: `com.example.localMusicPlayer` (or your bundle ID)
   - App nickname: "Local Music Player iOS"
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/GoogleService-Info.plist`
5. Update `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

### 4. Enable Firebase Services

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable Email/Password
3. Enable Google Sign-In:
   - Add support email
   - Configure OAuth consent screen
   - Add authorized domains

#### Firestore Database
1. Go to Firestore Database
2. Create database:
   - Start in test mode (for development)
   - Choose location
3. Set up security rules (see below)

### 5. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's tracks
      match /tracks/{trackId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Admins can read all user data
    function isAdmin() {
      return request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /users/{userId} {
      allow read: if isAdmin();
    }
  }
}
```

## Android Deployment

### 1. Configure Signing

Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/keystore.jks
```

### 2. Update build.gradle

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Build APK

```bash
flutter build apk --release
```

### 4. Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 5. Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Upload app bundle
4. Fill in store listing
5. Submit for review

## iOS Deployment

### 1. Configure Signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your team
5. Enable Automatically manage signing

### 2. Update Info.plist

Add required permissions and configurations.

### 3. Build for Release

```bash
flutter build ios --release
```

### 4. Archive in Xcode

1. Open Xcode
2. Product → Archive
3. Distribute App
4. Choose distribution method (App Store, Ad Hoc, etc.)

### 5. Upload to App Store

1. Use Xcode Organizer
2. Upload to App Store Connect
3. Submit for review in App Store Connect

## Web Deployment

### 1. Build for Web

```bash
flutter build web --release
```

### 2. Deploy Options

#### Firebase Hosting
```bash
firebase init hosting
firebase deploy --only hosting
```

#### Netlify
1. Connect repository to Netlify
2. Build command: `flutter build web`
3. Publish directory: `build/web`

#### GitHub Pages
1. Build web app
2. Copy `build/web` contents to `docs` folder
3. Enable GitHub Pages in repository settings

## Environment Configuration

### Development
- Use Firebase test mode
- Enable debug logging
- Use development API keys

### Production
- Use Firebase production mode
- Disable debug logging
- Use production API keys
- Enable analytics
- Set up error tracking (Firebase Crashlytics)

## Testing Before Deployment

1. **Unit Tests**
   ```bash
   flutter test
   ```

2. **Widget Tests**
   ```bash
   flutter test test/widget_tests/
   ```

3. **Integration Tests**
   ```bash
   flutter test integration_test/
   ```

4. **Manual Testing Checklist**
   - [ ] Authentication (Email, Google)
   - [ ] CRUD operations
   - [ ] Cloud sync
   - [ ] Offline mode
   - [ ] Workflow transitions
   - [ ] Reporting
   - [ ] Export functionality

## Post-Deployment

1. Monitor Firebase Console for errors
2. Set up Firebase Analytics
3. Configure Firebase Crashlytics
4. Set up performance monitoring
5. Monitor user feedback

## Troubleshooting

### Android Build Issues
- Check `google-services.json` is in correct location
- Verify signing configuration
- Check ProGuard rules if using code obfuscation

### iOS Build Issues
- Verify `GoogleService-Info.plist` is added to Xcode project
- Check signing certificates
- Verify Info.plist configurations

### Firebase Issues
- Verify API keys are correct
- Check security rules
- Verify authentication providers are enabled

## Security Checklist

- [ ] API keys are not hardcoded
- [ ] Firestore security rules are configured
- [ ] Authentication is properly implemented
- [ ] Sensitive data is encrypted
- [ ] App signing is configured
- [ ] ProGuard/R8 rules are set (Android)

## Performance Optimization

1. Enable code obfuscation (release builds)
2. Optimize images and assets
3. Use lazy loading for lists
4. Implement caching strategies
5. Monitor performance metrics

---

For more information, see the main README.md file.
