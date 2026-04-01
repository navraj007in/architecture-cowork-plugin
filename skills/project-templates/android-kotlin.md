---
name: project-templates-android-kotlin
description: Starter file templates and boilerplate for scaffolding native Android apps with Kotlin and Jetpack Compose — project structure, networking (Retrofit), auth (EncryptedSharedPreferences), push notifications (FCM), deep linking
type: skill-extension
parent: project-templates
---

# Android (Kotlin / Jetpack Compose) Project Templates

## Native Android — Kotlin / Jetpack Compose

**Initialization:**
Native Android projects require Android Studio. There is no CLI scaffolder — write project files directly.

**Minimum SDK:** API 26 (Android 8.0)  
**Target SDK:** API 35  
**Language:** Kotlin 2.0+  
**UI framework:** Jetpack Compose  
**Build system:** Gradle (Kotlin DSL — `.kts`)  
**Architecture:** MVVM + Repository pattern

---

## Project Structure

```
{{component-name}}/
├── app/
│   ├── build.gradle.kts
│   ├── src/
│   │   ├── main/
│   │   │   ├── AndroidManifest.xml
│   │   │   ├── java/com/{{org}}/{{componentNameCamel}}/
│   │   │   │   ├── MainActivity.kt                  — Compose entry point
│   │   │   │   ├── {{ComponentName}}Application.kt  — Application subclass
│   │   │   │   ├── core/
│   │   │   │   │   ├── network/
│   │   │   │   │   │   ├── ApiClient.kt             — Retrofit + OkHttp
│   │   │   │   │   │   └── ApiService.kt            — Retrofit interface
│   │   │   │   │   ├── auth/
│   │   │   │   │   │   └── TokenStorage.kt          — EncryptedSharedPreferences
│   │   │   │   │   ├── push/
│   │   │   │   │   │   └── FcmService.kt            — FirebaseMessagingService
│   │   │   │   │   └── di/
│   │   │   │   │       └── AppModule.kt             — Hilt module
│   │   │   │   └── features/
│   │   │   │       └── {{responsibility}}/
│   │   │   │           ├── {{Responsibility}}Screen.kt
│   │   │   │           ├── {{Responsibility}}ViewModel.kt
│   │   │   │           └── {{Responsibility}}Repository.kt
│   │   │   └── res/
│   │   │       ├── values/strings.xml
│   │   │       └── xml/network_security_config.xml
│   │   └── test/
│   │       └── java/com/{{org}}/{{componentNameCamel}}/
│   │           └── ExampleUnitTest.kt
├── build.gradle.kts
├── gradle.properties
├── settings.gradle.kts
├── .gitignore
└── README.md
```

---

## Gradle — settings.gradle.kts

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "{{ComponentName}}"
include(":app")
```

---

## Gradle — app/build.gradle.kts

```kotlin
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.hilt)
    alias(libs.plugins.ksp)
    alias(libs.plugins.google.services)
}

android {
    namespace = "com.{{org}}.{{componentNameCamel}}"
    compileSdk = 35

    defaultConfig {
        applicationId = "{{bundle-id-android}}"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "0.1.0"

        buildConfigField("String", "API_BASE_URL", "\"${project.findProperty("API_BASE_URL") ?: "http://10.0.2.2:3000"}\"")
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}

dependencies {
    // Compose BOM
    val composeBom = platform("androidx.compose:compose-bom:2024.12.01")
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.navigation:navigation-compose:2.8.4")
    debugImplementation("androidx.compose.ui:ui-tooling")

    // Lifecycle / ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")

    // Hilt (DI)
    implementation("com.google.dagger:hilt-android:2.52")
    ksp("com.google.dagger:hilt-android-compiler:2.52")
    implementation("androidx.hilt:hilt-navigation-compose:1.2.0")

    // Networking
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")

    // Auth storage
    implementation("androidx.security:security-crypto:1.1.0-alpha06")

    // Firebase (push notifications)
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
}
```

---

## Entry Points

**{{ComponentName}}Application.kt:**
```kotlin
package com.{{org}}.{{componentNameCamel}}

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class {{ComponentName}}Application : Application()
```

**MainActivity.kt:**
```kotlin
package com.{{org}}.{{componentNameCamel}}

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                // TODO: Replace with NavHost / root composable
                AppNavGraph()
            }
        }
    }
}
```

---

## Networking — Retrofit

**core/network/ApiClient.kt:**
```kotlin
package com.{{org}}.{{componentNameCamel}}.core.network

import com.{{org}}.{{componentNameCamel}}.BuildConfig
import com.{{org}}.{{componentNameCamel}}.core.auth.TokenStorage
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.UUID

object ApiClient {
    fun create(tokenStorage: TokenStorage): Retrofit {
        val authInterceptor = Interceptor { chain ->
            val token = tokenStorage.getToken()
            val request = chain.request().newBuilder()
                .apply { if (token != null) header("Authorization", "Bearer $token") }
                .header("X-Correlation-ID", UUID.randomUUID().toString())
                .build()
            chain.proceed(request)
        }

        val logging = HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) HttpLoggingInterceptor.Level.BODY
                    else HttpLoggingInterceptor.Level.NONE
        }

        val client = OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(logging)
            .build()

        return Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
}
```

**core/network/ApiService.kt:**
```kotlin
package com.{{org}}.{{componentNameCamel}}.core.network

import retrofit2.http.GET

interface ApiService {
    @GET("/health")
    suspend fun health(): Map<String, String>

    // TODO: Add endpoints matching the OpenAPI contract for this service
}
```

---

## Auth — EncryptedSharedPreferences

**core/auth/TokenStorage.kt:**
```kotlin
package com.{{org}}.{{componentNameCamel}}.core.auth

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TokenStorage @Inject constructor(@ApplicationContext context: Context) {

    private val prefs = EncryptedSharedPreferences.create(
        context,
        "{{component-name}}_secure_prefs",
        MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun getToken(): String? = prefs.getString("auth_token", null)

    fun setToken(token: String) = prefs.edit().putString("auth_token", token).apply()

    fun clearToken() = prefs.edit().remove("auth_token").apply()
}
```

---

## Push Notifications — FCM

**core/push/FcmService.kt:**
```kotlin
package com.{{org}}.{{componentNameCamel}}.core.push

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FcmService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        // TODO: Send token to backend for storage
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        // TODO: Display notification using NotificationManager
        // message.notification?.title, message.notification?.body
        // message.data for data payloads
    }
}
```

---

## AndroidManifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <!-- TODO: Add permissions from manifest permissions[] -->

    <application
        android:name=".{{ComponentName}}Application"
        android:label="@string/app_name"
        android:networkSecurityConfig="@xml/network_security_config"
        android:theme="@style/Theme.AppCompat">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- Deep linking URL scheme: {{deep-linking-scheme}}:// -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="{{deep-linking-scheme}}" />
            </intent-filter>
        </activity>

        <service
            android:name=".core.push.FcmService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

    </application>
</manifest>
```

---

## res/xml/network_security_config.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Allow cleartext to local dev server only -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="false">10.0.2.2</domain>
        <domain includeSubdomains="false">localhost</domain>
    </domain-config>
</network-security-config>
```

---

## .gitignore

```
*.iml
.gradle/
.idea/
local.properties
.DS_Store
build/
captures/
.externalNativeBuild/
.cxx/
google-services.json    # contains Firebase config — add as CI secret
```

---

## CI Workflow

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          java-version: 17
          distribution: temurin

      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v4

      - name: Build debug APK
        run: ./gradlew assembleDebug

      - name: Run unit tests
        run: ./gradlew test
```

> **Note:** `google-services.json` must be added as a CI secret and written to `app/google-services.json` before the build step if using Firebase. Add a step:
> ```yaml
> - name: Write google-services.json
>   run: echo "${{ secrets.GOOGLE_SERVICES_JSON }}" > app/google-services.json
> ```
