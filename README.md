# docker-xamarin-android

Forked from [chiticariu's Fedora 27 Xamarin build image](https://github.com/chiticariu/xamarin-android) but updated to Android SDK 30, based on [rheuvel89's Ubuntu 20.04 Xamarin build image](https://github.com/rheuvel89/xamarin-android/). This image uses the Android SDK so you should agree with the Android SDK license before usage (https://developer.android.com/studio/terms.html)

## Example `.gitlab-ci` file

```
image: sakurina/xamarin-android

stages:
    - build

before_script:
    - export BUILD_DATE=$(date +%Y%m%d%H%M%S)

build:
    stage: build
    only:
        - master
    artifacts:
      paths:
        - publish_android/*.apk
    script:
      - msbuild src/<solution_file_name>.sln /p:AndroidSdkDirectory=/android/sdk /p:AndroidNdkDirectory=/android/sdk/ndk-bundle /p:Configuration="Release" /p:Platform="Any CPU" /restore
      - msbuild src/<android_project_directory>/<android_project_file_name>.csproj /p:AndroidSdkDirectory=/android/sdk /p:AndroidNdkDirectory=/android/sdk/ndk-bundle /p:Configuration="Release" /p:Platform="Any CPU" /t:PackageForAndroid /p:OutputPath="../../publish_android/"
      - msbuild src/<android_project_directory>/<android_project_file_name>.csproj /p:AndroidSdkDirectory=/android/sdk /p:AndroidNdkDirectory=/android/sdk/ndk-bundle /p:Configuration="Release" /p:Platform="Any CPU" /t:SignAndroidPackage /p:OutputPath="../../publish_android/"

```

## Extra helper command

- Run docker image in terminal having the code mounted

```
Linux:    docker run -it -v $(pwd):/xamarin_project sakurina/xamarin-android /bin/bash
Windows:  docker run -it -v %cd%:/xamarin_project sakurina/xamarin-android /bin/bash
```
