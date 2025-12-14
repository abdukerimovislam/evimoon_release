allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    afterEvaluate {
        // --- ПАТЧ ДЛЯ ISAR (Kotlin DSL версия) ---
        if (project.name == "isar_flutter_libs") {
            try {
                // В Kotlin DSL мы должны явно обратиться к расширению LibraryExtension
                project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                    namespace = "dev.isar.isar_flutter_libs"
                }
            } catch (e: Throwable) {
                // Если вдруг класс не найден, пробуем через динамический доступ (fallback)
                project.extensions.findByName("android")?.apply {
                    val namespaceProp = this::class.members.find { it.name == "namespace" }
                    if (namespaceProp is kotlin.reflect.KMutableProperty<*>) {
                        namespaceProp.setter.call(this, "dev.isar.isar_flutter_libs")
                    }
                }
            }
        }
        // ----------------------------------------
    }

    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
}