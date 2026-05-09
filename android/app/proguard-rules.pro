# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Razorpay
-keepclassmembers class com.razorpay.** { *; }
-keep class com.razorpay.** { *; }
-optimizations !method/inlining/*
-keepattributes *Annotation*
-keepattributes Signature
-dontwarn com.razorpay.**

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
