plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ardakadi.productivityapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Flag to enable support for the new language APIs (flutter_local_notifications
        // requires core library desugaring - see FAZ 1.6 notes).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.ardakadi.productivityapp"
        // minSdk 24 (FAZ 1.6 karar guncellemesi): baslangicta minSdk 21
        // planlanmisti, ancak bu Flutter SDK surumunun MinSdkVersionMigration
        // araci minSdk 16-23 araligindaki her degeri otomatik olarak
        // flutter.minSdkVersion'a (bu surumde 24) geri ceviriyor - Flutter
        // engine artik API 24 altini desteklemiyor. minSdk 21 bu nedenle
        // teknik olarak uygulanamaz; 24 acikca yazilir ki migration araci
        // sessizce degistirmesin, karar burada belgelenmis olsun.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // flutter_local_notifications requires core library desugaring (see compileOptions above).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
