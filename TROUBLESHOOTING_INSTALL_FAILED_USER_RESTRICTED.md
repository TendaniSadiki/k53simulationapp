# Fix: INSTALL_FAILED_USER_RESTRICTED Error

## Problem
The error `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user` occurs when Android blocks app installation from unknown sources or due to security restrictions.

## Quick Solutions

### Solution 1: Enable "Install Unknown Apps"
1. **On your Android device**, go to **Settings** → **Apps & notifications** → **Special app access** → **Install unknown apps**
2. **Find your browser** (Chrome, Firefox, etc.) or **File Manager** app
3. **Enable "Allow from this source"**

### Solution 2: Enable USB Debugging (Install via USB)
1. **Enable Developer Options** (tap Build Number 7 times in About Phone)
2. Go to **Settings** → **Developer Options**
3. **Enable USB Debugging**
4. **Enable "USB Debugging (Security Settings)"** if available
5. **Enable "Install via USB"** if available

### Solution 3: Disable Play Protect
1. Open **Google Play Store**
2. Tap **Profile icon** → **Play Protect**
3. **Turn off "Scan apps with Play Protect"**

### Solution 4: Use ADB Commands
Try these commands in your terminal:

```bash
# Grant install permissions
adb shell pm grant com.example.k53app android.permission.INSTALL_PACKAGES

# Or try installing with different flags
adb install -r -g build\app\outputs\flutter-apk\app-debug.apk
```

## Step-by-Step Fix

### Step 1: Check Current Permissions
```bash
# List all connected devices
adb devices

# Check if device is authorized
# Should show "device" not "unauthorized"
```

### Step 2: Clear Previous Installations
```bash
# Uninstall any existing version
adb uninstall com.example.k53app

# Clear app data
adb shell pm clear com.example.k53app
```

### Step 3: Try Alternative Installation Methods

#### Method A: Install via ADB with Grant
```bash
adb install -g build\app\outputs\flutter-apk\app-debug.apk
```

#### Method B: Push and Install
```bash
adb push build\app\outputs\flutter-apk\app-debug.apk /sdcard/
adb shell pm install -r -g /sdcard/app-debug.apk
```

#### Method C: Use Flutter with Different Flags
```bash
flutter run -d 2409BRN2CA --no-fast-start
```

### Step 4: Device-Specific Settings

#### For Samsung Devices:
1. Go to **Settings** → **Biometrics and security** → **Install unknown apps**
2. Enable for your file manager/browser

#### For Huawei Devices:
1. Go to **Settings** → **Security & privacy** → **More settings**
2. Enable **External sources** or **Unknown sources**

#### For Xiaomi Devices:
1. Go to **Settings** → **Additional settings** → **Privacy**
2. Enable **Unknown sources**
3. Also check **Security** app → **Permissions** → **Install via USB**

## Alternative: Build and Install Manually

### Build Release APK
```bash
flutter build apk --release
```

### Install Manually
1. Copy `build\app\outputs\flutter-apk\app-release.apk` to your device
2. Use a file manager to install it
3. **Allow installation** when prompted

## Testing the Fix

After applying the fixes, try running again:

```bash
flutter run -d 2409BRN2CA
```

## If Still Not Working

### Check Device Logs
```bash
adb logcat | grep -i "install"
```

### Reset ADB Connection
```bash
adb kill-server
adb start-server
adb devices
```

### Try Different USB Port/Cable
- Use a different USB port on your computer
- Try a different USB cable (some cables are charge-only)
- Restart both computer and phone

## Success Indicators

When it works, you should see:
- App building successfully (√ Built build\app\outputs\flutter-apk\app-debug.apk)
- Installation proceeding without "INSTALL_FAILED_USER_RESTRICTED"
- App launching on your device

## Common Causes
- **Security settings** blocking unknown sources
- **Play Protect** interfering with installation
- **USB debugging** not properly enabled
- **Previous app version** causing conflicts
- **Device manufacturer restrictions** (Samsung, Huawei, Xiaomi have extra security)

Try these solutions in order, and the app should install successfully on your device!