FROM fedora:28
MAINTAINER Yanik Magnan <kirbykirbykirby@gmail.com>

# Install mono
RUN dnf install gnupg wget dnf-plugins-core -y  \
	&& rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" \
	&& dnf config-manager --add-repo http://download.mono-project.com/repo/centos7/ \
        && dnf install libzip bzip2 bzip2-libs mono-devel nuget msbuild referenceassemblies-pcl lynx -y \
        && dnf clean all

# Install dotnet core 3.1
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN wget -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/fedora/28/prod.repo
RUN dnf install dotnet-sdk-3.1 dotnet-runtime-3.1 -y && \ 
    dnf clean all

# Install JDK
RUN dnf install curl unzip java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel -y && \
    dnf clean all
    
# Install Android SDK
RUN mkdir -p /android/sdk && \
    curl -k https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -o sdk-tools-linux-latest.zip && \
    unzip -q sdk-tools-linux-latest.zip -d /android/sdk && \
    rm sdk-tools-linux-latest.zip

RUN cd /android/sdk && \
    yes | ./cmdline-tools/bin/sdkmanager --sdk_root=/android/sdk/ --licenses && \
    ./cmdline-tools/bin/sdkmanager --sdk_root=/android/sdk/ 'build-tools;30.0.2' platform-tools 'platforms;android-30' 'ndk-bundle'

# Install Xamarin
RUN mkdir -p /tmp/xamarin-linux && \
    curl -L "https://artprodcus3.artifacts.visualstudio.com/Ad0adf05a-e7d7-4b65-96fe-3f3884d42038/6fd3d886-57a5-4e31-8db7-52a1b47c07a8/_apis/artifact/cGlwZWxpbmVhcnRpZmFjdDovL3hhbWFyaW4vcHJvamVjdElkLzZmZDNkODg2LTU3YTUtNGUzMS04ZGI3LTUyYTFiNDdjMDdhOC9idWlsZElkLzU0OTUzL2FydGlmYWN0TmFtZS9pbnN0YWxsZXJzLXVuc2lnbmVkKy0rTGludXg1/content?format=zip" \
        -o /tmp/xamarin-linux.zip && \
    unzip -q /tmp/xamarin-linux.zip -d /tmp/xamarin-linux && \
    rm /tmp/xamarin-linux.zip && \
    cd "/tmp/xamarin-linux/installers-unsigned - Linux" && \
    bzip2 -cd xamarin.android-oss-v12.2.99.0_Linux-x86_64_main_51320b7b-Release.tar.bz2 | tar -xvf - && \
    mv xamarin.android-oss-v12.2.99.0_Linux-x86_64_main_51320b7b-Release /android/xamarin && \
    ln -s /android/xamarin/bin/Release/lib/xamarin.android/xbuild/Xamarin /usr/lib/mono/xbuild/Xamarin && \
    ln -s /android/xamarin/bin/Release/lib/xamarin.android/xbuild-frameworks/MonoAndroid/ /usr/lib/mono/xbuild-frameworks/MonoAndroid && \
    ln -s /usr/lib64/libzip.so.5 /usr/lib64/libzip.so.4 && \
    rm -rf /tmp/xamarin-linux
    
# Set up env variables
ENV ANDROID_NDK_PATH=/android/sdk/ndk-bundle
ENV ANDROID_HOME=/android/sdk/
ENV PATH=/android/xamarin/bin/Release/bin:$PATH
ENV JAVA_HOME=/usr/lib/jvm/java/