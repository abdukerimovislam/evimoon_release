import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // ❌ УДАЛЕНО: id("com.google.gms.google-services") — нам это не нужно без Firebase
}

// Загрузка ключей
val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.midas.evimoon"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Настройка подписи
    signingConfigs {
        create("release") {
            // Безопасное чтение. Если ключа нет, сборка просто не подпишется (но не упадет на этапе конфига)
            keyAlias = keyProperties.getProperty("keyAlias")
            keyPassword = keyProperties.getProperty("keyPassword")
            val storeFilePath = keyProperties.getProperty("storeFile")
            storeFile = if (storeFilePath != null) file(storeFilePath) else null
            storePassword = keyProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        applicationId = "com.midas.evimoon"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Подписываем релизным ключом
            signingConfig = signingConfigs.getByName("release")

            // 🔥 ВАЖНО: Выключаем сжатие для Hive, чтобы приложение не падало
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1")
    // Поддержка новых фич Java на старых Android
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}