[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/WolfTheZelda/Flybis) 

# Flybis

Esse é o repositório Git no GitHub para o projeto Flybis.

# Git

Instruções básicas para uso do Git:

## Adicionar arquivos

    git add *

## Criar novo commit

    git commit -m "TEXTO"

## Enviar commit

    git push origin master

## Atualizar repositório local

    git pull

# Flutter

Instruções básicas para uso do Flutter:

## Compilar splash

    flutter pub run flutter_native_splash:create

## Compilar icons

    flutter pub run flutter_launcher_icons:main

## Compilar build APK

    flutter build apk --release --tree-shake-icons --shrink --obfuscate --split-per-abi --split-debug-info=./.debug_info/android/

## Compilar build APPBUNDLE

    flutter build appbundle --release --tree-shake-icons --shrink --split-debug-info=./.debug_info/android/ --obfuscate --target-platform android-arm,android-arm64,android-x64

## Ativar build WEB

    flutter config --enable-web

## Compilar build WEB

    flutter run -d chrome --release --dart-define=FLUTTER_WEB_USE_SKIA=true

## Definir config do functions localmente

    firebase functions:config:get > .runtimeconfig.json

# Gcloud

Instruções básicas para uso do Gcloud:

## Iniciar projeto Gcloud

    gcloud init

## Instalar SDK (PowerShell)

    (New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
    & $env:Temp\GoogleCloudSDKInstaller.exe

## Setar cors.json usando o gsutil

    gsutil cors set cors.json gs://flybis.appspot.com

# Requisitos

Esses são os requisitos necessários para a utilização do projeto:

|Nome|Link|Console|
|----------------|-------------------------------|-----------------------------|
|NodeJS 10|`[https://nodejs.org/dist/latest-v10.x/](https://nodejs.org/dist/latest-v10.x/)`||
|Yarn|`[https://classic.yarnpkg.com/latest.msi](https://classic.yarnpkg.com/latest.msi)`||
|Firebase Tools|`npm i -g firebase-tools`||
|Flutter|`[https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)`||
|Android Studio|`[https://developer.android.com/studio](https://developer.android.com/studio)`||