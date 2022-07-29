-ignorewarnings

## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

## Firebase
#-keep class com.google.firebase.iid.FirebaseInstanceId { zza(...); }
-keep class com.google.firebase.** { *; }
-keep class com.google.gms.** { *; }
-keep class io.fabric.** { *; }

## Agora.io
-keep class io.agora.** { *; }

## Admob Consent
# Keep classes of this plugin
-keep class com.anteger.** { *; }
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature
# For using GSON @Expose annotation
-keepattributes *Annotation*
# Gson specific classes
-dontwarn sun.misc.**
#-keep class com.google.gson.stream.** { *; }
# Application classes that will be serialized/deserialized over Gson
-keep class com.google.gson.examples.android.model.** { <fields>; }
# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

## Kotlin
-keepattributes *Annotation*
-keep class kotlin.** { *; }
-keep class org.jetbrains.** { *; }

## Prevent Proguard Error
#-keepattributes EnclosingMethod
#-keepattributes InnerClasses