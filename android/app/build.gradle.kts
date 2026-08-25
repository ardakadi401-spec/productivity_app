import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// FAZ 18 — Release imzalama. `key.properties` bilinçli olarak .gitignore'da
// (bkz. proje kökü .gitignore) — bu dosya yerelde/CI sırlarında bulunmazsa
// (örn. temiz bir checkout) `signingConfigs.release` sessizce debug
// anahtarına düşer, böylece `flutter run --release`/CI build'leri
// key.properties olmadan da kırılmadan çalışmaya devam eder.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // `key.properties` yoksa (örn. temiz bir checkout/CI) debug
            // anahtarına düşülür — bkz. yukarıdaki `hasReleaseSigning` notu.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // ROADMAP.md FAZ 18 "release build konfigürasyonunun (ProGuard/R8...)
            // hazırlanması" — kod küçültme + kaynak küçültme etkin.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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
