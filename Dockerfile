# KeePassXC Linux CI Build Dockerfile
# Copyright (C) 2017-2019 KeePassXC team <https://keepassxc.org/>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 or (at your option)
# version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM ubuntu:16.04

ENV REBUILD_COUNTER=3
ENV QT5_VERSION=qt515
ENV QT5_PPA_VERSION=qt-5.15.2

RUN set -x \
    && apt-get update -y \
    && apt-get -y install --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
    && add-apt-repository ppa:beineri/opt-${QT5_PPA_VERSION}-xenial \
    && add-apt-repository ppa:phoerious/keepassxc \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        asciidoctor \
        build-essential \
        clang-4.0 \
        cmake \
        curl \
        dbus \
        file \
        fuse \
        git \
        libargon2-0-dev \
        libbotan-kpxc-2-dev \
        libclang-common-4.0-dev \
        libgl1-mesa-dev \
        libgcrypt20-18-dev \
        libomp-dev \
        libqrencode-dev \
        libquazip5-dev \
        libsodium-dev \
        libxi-dev \
        libxtst-dev \
        libyubikey-dev \
        libykpers-1-dev \
        llvm-4.0 \
        locales \
        metacity \
        ${QT5_VERSION}base \
        ${QT5_VERSION}imageformats \
        ${QT5_VERSION}svg \
        ${QT5_VERSION}tools \
        ${QT5_VERSION}translations \
        ${QT5_VERSION}x11extras \
        xclip \
        xvfb \
        zlib1g-dev \
        openssh-client \
        asciidoctor \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/
    
# Install clang-format-10 to support proper code formatting checks    
RUN set -x \
    && curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-10 main" \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y \
        clang-format-10 \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && ln -s /usr/bin/clang-format-10 /usr/bin/clang-format

RUN set -x \
    && git clone https://github.com/ncopa/su-exec.git \
    && (cd su-exec; make) \
    && mv su-exec/su-exec /usr/bin/su-exec \
    && rm -rf su-exec

RUN set -x && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV PATH="/opt/${QT5_VERSION}/bin:${PATH}"
ENV CMAKE_PREFIX_PATH="/opt/${QT5_VERSION}/lib/cmake"
ENV CMAKE_INCLUDE_PATH="/opt/keepassxc-libs/include"
ENV CMAKE_LIBRARY_PATH="/opt/keepassxc-libs/lib/x86_64-linux-gnu"
ENV CPATH="${CMAKE_INCLUDE_PATH}"
ENV LD_LIBRARY_PATH="${CMAKE_LIBRARY_PATH}:/opt/${QT5_VERSION}/lib"

RUN set -x \
    && echo "/opt/keepassxc-libs/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/01-keepassxc.conf \
    && echo "/opt/${QT5_VERSION}/lib" > /etc/ld.so.conf.d/02-${QT5_VERSION}.conf \
    && ldconfig

RUN set -x \
    && curl -fL "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" > /usr/bin/linuxdeploy \
    && curl -fL "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage" > /usr/bin/linuxdeploy-plugin-qt \
    && curl -fL "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" > /usr/bin/appimagetool \
    && chmod +x /usr/bin/linuxdeploy \
    && chmod +x /usr/bin/linuxdeploy-plugin-qt \
    && chmod +x /usr/bin/appimagetool

RUN set -x \
    && groupadd -g 1000 keepassxc \
    && useradd -u 1000 -g keepassxc -d /keepassxc -s /bin/bash keepassxc

COPY docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["/keepassxc/src", "/keepassxc/out"]
WORKDIR /keepassxc
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bashx"]
