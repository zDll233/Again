import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 签名配置: 本地/CI 存在 android/key.properties (gitignored) 时用正式签名,
// 否则回退 debug 签名 (开发构建可用)。
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.zdl.again"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.zdl.again"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            // debug 包用 debug 密钥, 无法覆盖安装上传密钥签名的正式版,
            // 因此加 .dev 后缀作为独立应用共存 (正式版数据不受影响)。
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        release {
            // 只保留 arm64-v8a: Flutter 自身在 CI 用 --target-platform android-arm64
            // 只出 arm64, 但插件 (sqlite3_flutter_libs) 的预编译 .so 会把所有 ABI
            // 各带一份 (约 3MB 死重), 这里一并裁掉。
            ndk {
                abiFilters.clear()
                abiFilters.add("arm64-v8a")
            }
            // 有 key.properties 用正式签名, 否则 debug 签名 (便于本地直接 run)
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
