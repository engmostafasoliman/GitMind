import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing properties from key.properties (local) or environment variables (CI)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.codemind.chatyaiagent"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(
                keystoreProperties["storeFile"] as? String
                    ?: System.getenv("KEYSTORE_PATH") ?: "keystore.jks"
            )
            storePassword = keystoreProperties["storePassword"] as? String
                ?: System.getenv("KEY_STORE_PASSWORD") ?: ""
            keyAlias = keystoreProperties["keyAlias"] as? String
                ?: System.getenv("KEY_ALIAS") ?: ""
            keyPassword = keystoreProperties["keyPassword"] as? String
                ?: System.getenv("KEY_PASSWORD") ?: ""
        }
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationId = "com.codemind.chatyaiagent.dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "GitMind Dev")
        }
        create("prod") {
            dimension = "environment"
            applicationId = "com.codemind.chatyaiagent"
            resValue("string", "app_name", "GitMind")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
