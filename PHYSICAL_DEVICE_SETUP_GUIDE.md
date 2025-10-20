# Running K53 App on Physical Device

## Prerequisites

### 1. Development Environment Setup
- **Flutter SDK** installed and configured
- **Android Studio** or **VS Code** with Flutter extension
- **Java JDK** (for Android development)
- **Xcode** (for iOS development - macOS only)

### 2. Physical Device Requirements
- **Android**: Android 5.0 (API level 21) or higher
- **iOS**: iOS 11.0 or higher
- **Enable Developer Options** on your device

## Step-by-Step Setup

### For Android Devices

#### 1. Enable Developer Options
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times until "You are now a developer!" appears
3. Go back to **Settings** → **Developer Options**
4. Enable **USB Debugging**

#### 2. Connect Device via USB
1. Connect your Android device to your computer via USB cable
2. On your device, when prompted, allow USB debugging
3. Verify connection:
```bash
flutter devices
```
You should see your device listed.

#### 3. Run the App
```bash
# From the project root directory
flutter run
```

### For iOS Devices

#### 1. Apple Developer Account
- You need an Apple Developer account ($99/year) for physical device testing
- Or use a free account with limitations

#### 2. Xcode Setup
1. Open Xcode
2. Go to **Xcode** → **Preferences** → **Accounts**
3. Add your Apple ID
4. Connect your iOS device via USB

#### 3. Configure Signing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project in the navigator
3. Go to **Signing & Capabilities** tab
4. Select your team for automatic signing

#### 4. Trust Developer
1. On your iOS device, go to **Settings** → **General** → **Device Management**
2. Trust your developer certificate

#### 5. Run the App
```bash
flutter run
```

## Alternative: Build APK/IPA Files

### Build Android APK
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# The APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

### Build iOS IPA
```bash
# Build for iOS (requires macOS and Xcode)
flutter build ios --release

# The IPA will be in the ios/build folder
```

## Testing the App

### 1. Test User Signup
1. Open the app on your device
2. Tap **"Don't have an account? Sign Up"**
3. Enter test credentials:
   - Email: `testuser_123@example.com`
   - Password: `testpassword123`
   - Full Name: `Test User`
   - Phone: `+1234567890`
4. Verify the signup process works

### 2. Test Database Connection
- Check console logs for database connection status
- Verify profile creation messages

## Troubleshooting

### Common Android Issues

#### Device Not Detected
```bash
# Check USB connection
adb devices

# Restart ADB server
adb kill-server
adb start-server
```

#### USB Debugging Not Working
- Try different USB cables
- Check if USB port is working
- Restart device and computer

### Common iOS Issues

#### Code Signing Errors
- Make sure you have a valid Apple Developer account
- Check Xcode signing settings
- Clean and rebuild:
```bash
flutter clean
flutter build ios
```

#### Device Trust Issues
- Go to **Settings** → **General** → **Device Management**
- Trust your developer certificate again

### Flutter-Specific Issues

#### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

#### Check Dependencies
```bash
flutter doctor
```

## Network Requirements

### For Database Connectivity
- Your device needs internet connection for Supabase database
- Make sure your device can reach the Supabase API endpoints

### Local Development
If testing locally, ensure your device and computer are on the same network.

## Performance Tips

### 1. Enable Skia Shader
```bash
flutter run --enable-skia
```

### 2. Build in Release Mode
```bash
flutter run --release
```

### 3. Profile Mode for Performance
```bash
flutter run --profile
```

## Next Steps After Testing

### 1. Verify All Features
- User registration and login
- Study mode functionality
- Exam mode functionality
- Gamification features
- Progress tracking

### 2. Performance Testing
- Test on different device models
- Check memory usage
- Verify battery impact

### 3. User Experience
- Test touch interactions
- Verify screen responsiveness
- Check navigation flow

## Deployment Options

### 1. Internal Testing
- Share APK directly for Android testing
- Use TestFlight for iOS testing

### 2. App Stores
- Google Play Store for Android
- Apple App Store for iOS

## Support

If you encounter issues:
1. Check `flutter doctor` output
2. Review console logs during build
3. Check device compatibility
4. Verify network connectivity

The K53 app should now run successfully on your physical device with all database and authentication features working properly!