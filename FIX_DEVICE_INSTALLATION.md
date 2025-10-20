# Fix: INSTALL_FAILED_USER_RESTRICTED Error

## Exact Error Message
```
adb.exe: failed to install C:\Users\EdmondSadiki\Desktop\code\my-projects\k53app\build\app\outputs\flutter-apk\app-debug.apk:   
Failure [INSTALL_FAILED_USER_RESTRICTED: Install canceled by user]
```

## Quick Solutions (Try in Order)

### Solution 1: Enable "Install Unknown Apps" (Most Common)
1. **On your Android device**, go to **Settings** → **Apps & notifications** → **Special app access** → **Install unknown apps**
2. **Find your browser** (Chrome, Firefox, etc.) or **File Manager** app
3. **Enable "Allow from this source"**

### Solution 2: Enable USB Debugging (Install via USB)
1. **Enable Developer Options**:
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times until "You are now a developer!" appears
2. Go to **Settings** → **Developer Options**
3. **Enable USB Debugging**
4. **Enable "USB Debugging (Security Settings)"** if available
5. **Enable "Install via USB"** if available

### Solution 3: Disable Play Protect
1. Open **Google Play Store**
2. Tap **Profile icon** → **Play Protect**
3. **Turn off "Scan apps with Play Protect"**

### Solution 4: Use ADB Commands (Advanced)
Open Command Prompt as Administrator and try:

```cmd
# Grant install permissions
adb shell pm grant com.example.k53app android.permission.INSTALL_PACKAGES

# Install with different flags
adb install -r -g build\app\outputs\flutter-apk\app-debug.apk

# Or push and install
adb push build\app\outputs\flutter-apk\app-debug.apk /sdcard/
adb shell pm install -r -g /sdcard/app-debug.apk
```

### Solution 5: Build Release APK and Install Manually
```cmd
flutter build apk --release
```
Then copy `build\app\outputs\flutter-apk\app-release.apk` to your device and install manually.

## Device-Specific Instructions

### For Samsung Devices:
1. Go to **Settings** → **Biometrics and security** → **Install unknown apps**
2. Enable for your file manager/browser

### For Huawei Devices:
1. Go to **Settings** → **Security & privacy** → **More settings**
2. Enable **External sources** or **Unknown sources**

### For Xiaomi Devices:
1. Go to **Settings** → **Additional settings** → **Privacy**
2. Enable **Unknown sources**
3. Also check **Security** app → **Permissions** → **Install via USB**

## Alternative: Use Emulator for Testing

If the physical device continues to block installation, use an Android emulator:

```cmd
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run on emulator
flutter run
```

## Verify ADB Connection

```cmd
# Check if device is detected
adb devices

# Should show your device ID with "device" status
# If it shows "unauthorized", you need to allow USB debugging
```

## Reset ADB Connection

```cmd
adb kill-server
adb start-server
adb devices
```

## Try Different USB Port/Cable

- Use a different USB port on your computer
- Try a different USB cable (some cables are charge-only)
- Restart both computer and phone

## Success Indicators

When it works, you should see:
- App building successfully (√ Built build\app\outputs\flutter-apk\app-debug.apk)
- Installation proceeding without "INSTALL_FAILED_USER_RESTRICTED"
- App launching on your device

## If Still Not Working

### Check Device Logs
```cmd
adb logcat | grep -i "install"
```

### Try Flutter with Different Flags
```cmd
flutter run -d 2409BRN2CA --no-fast-start
```

### Build for Web Instead
```cmd
flutter run -d chrome
```

## Common Causes
- **Security settings** blocking unknown sources
- **Play Protect** interfering with installation
- **USB debugging** not properly enabled
- **Previous app version** causing conflicts
- **Device manufacturer restrictions** (Samsung, Huawei, Xiaomi have extra security)

## Next Steps After Successful Installation

Once the app installs successfully, you'll need to:

1. **Update Supabase credentials** in `.env` file
2. **Deploy database migrations** to Supabase
3. **Test user registration** and database connectivity

The app is technically complete and ready to run once these installation and configuration issues are resolved.