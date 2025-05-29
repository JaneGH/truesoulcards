plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.truesoulcards"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.itclimb.truesoulcards"
        resValue("string", "flutter_env", project.findProperty("env") as String? ?: "dev")
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    ndkVersion = "27.0.12077973"

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
                    shrinkResources true
            minifyEnabled true
            proguardFiles getDefaultProguardFile(
                    'proguard-android-optimize.txt'),
            'proguard-rules.pro'
        }
    }
    dependencies {
        implementation("com.google.android.material:material:1.12.0")
    }

}

flutter {
    source = "../.."
}
