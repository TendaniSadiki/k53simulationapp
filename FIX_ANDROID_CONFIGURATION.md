# Fix Android Configuration Issues

## Problem Identified
The K53 app is using modern Kotlin DSL (`.kts` files) for Android configuration, which might be causing compatibility issues with your Flutter setup or device.

## Solution 1: Convert to Traditional Groovy Configuration

### Step 1: Create Traditional build.gradle Files

**Create `android/build.gradle`:**
```gradle
buildscript {
    ext.kotlin_version = '1.9.24'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.7.3'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

**Create `android/app/build.gradle`:**
```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace "com.example.k53app"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.example.k53app"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```

**Create `android/settings.gradle`:**
```gradle
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        if (flutterSdkPath == null) {
            throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
        }
        return flutterSdkPath
    }()
    settings.ext.flutterSdkPath = flutterSdkPath

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.7.3" apply false
    id "org.jetbrains.kotlin.android" version "1.9.24" apply false
}

include ":app"
```

### Step 2: Clean and Rebuild
```bash
# Clean the project
flutter clean

# Delete build directories
rm -rf build
rm -rf android/build

# Get dependencies
flutter pub get

# Try building again
flutter build apk --debug
```

## Solution 2: Fix Current Kotlin DSL Configuration

If you prefer to keep the Kotlin DSL, update the existing files:

**Update `android/app/build.gradle.kts`:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.k53app"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.k53app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")
}
```

## Solution 3: Check Flutter Configuration

**Check `android/local.properties`:**
```
flutter.sdk=C:\\path\\to\\flutter
flutter.versionName=1.0.0
flutter.versionCode=1
flutter.compileSdkVersion=34
flutter.minSdkVersion=21
flutter.targetSdkVersion=34
flutter.ndkVersion=27.0.12077973
```

## Solution 4: Alternative Build Methods

### Build for Web
```bash
flutter run -d chrome
```

### Build Release APK
```bash
flutter build apk --release
# Then install manually
```

### Use Emulator
```bash
flutter emulators --launch Pixel_4_API_34
flutter run
```

## Solution 5: Device-Specific Fix

### Enable Developer Options
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times
3. Go to **Developer Options**
4. Enable **USB Debugging**
5. Enable **Install via USB**

### Enable Unknown Sources
1. Go to **Settings** → **Apps & notifications** → **Special app access**
2. Enable **Install unknown apps** for your browser/file manager

## Verification Steps

After applying fixes:

1. **Check build**: `flutter build apk --debug`
2. **Check installation**: `flutter install`
3. **Test run**: `flutter run -d 2409BRN2CA`

## Expected Success

When fixed, you should see:
- ✅ Building successfully
- ✅ Installing without "INSTALL_FAILED_USER_RESTRICTED"
- ✅ App launching on device
- ✅ K53 app interface appearing

The app code is technically sound - the issue is purely with Android build configuration and device permissions.