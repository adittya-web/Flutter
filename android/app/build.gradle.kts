// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ plugin Google Services
}

android {
    namespace = "com.example.tugaskelompok"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.tugaskelompok" // ✅ Ganti sesuai App ID
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // ✅ Wajib untuk Firebase
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // default debug key
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.firebase:firebase-analytics:21.5.0") // ✅ Firebase analytics
    implementation("com.google.android.gms:play-services-auth:20.7.0") // ✅ Google Sign-In
    implementation("androidx.multidex:multidex:2.0.1")
}
