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

ENV REBUILD_COUNTER=1

RUN set -x \
    && apt-get update -y \
    && apt-get -y install --no-install-recommends software-properties-common \
    && add-apt-repository ppa:phoerious/keepassxc \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        build-essential \
        clang-4.0 \
        clang-format-4.0 \
        cmake \
        curl \
        fuse \
        git \
        libargon2-0-dev \
        libclang-common-4.0-dev \
        libgcrypt20-18-dev \
        libqrencode-dev \
        libqt5svg5-dev \
        libqt5x11extras5-dev \
        libquazip5-dev \
        libsodium-dev \
        libxi-dev \
        libxtst-dev \
        libyubikey-dev \
        libykpers-1-dev \
        llvm-4.0 \
        locales \
        mesa-common-dev \
        qt5-image-formats-plugins \
        qtbase5-dev \
        qtbase5-dev-tools \
        qttools5-dev \
        qttools5-dev-tools \
        qttranslations5-l10n \
        xclip \
        xvfb \
        zlib1g-dev \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/
    
# Install clang-format-8 to support proper code formatting checks    
RUN set -x \
    && curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y \
        clang-format-8 \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && ln -s /usr/bin/clang-format-8 /usr/bin/clang-format

RUN set -x \
    && git clone https://github.com/ncopa/su-exec.git \
    && (cd su-exec; make) \
    && mv su-exec/su-exec /usr/bin/su-exec \
    && rm -rf su-exec

RUN set -x && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV CMAKE_INCLUDE_PATH="/opt/keepassxc-libs/include"
ENV CMAKE_LIBRARY_PATH="/opt/keepassxc-libs/lib/x86_64-linux-gnu"
ENV CPATH="${CMAKE_INCLUDE_PATH}"

RUN set -x \
    && echo "/opt/keepassxc-libs/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/01-keepassxc.conf \
    && ldconfig

RUN set -x \
    && curl -fL "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" > /usr/bin/linuxdeploy \
    && curl -fL "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage" > /usr/bin/linuxdeploy-plugin-qt \
    && curl -fL "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" > /usr/bin/appimagetool \
    && chmod +x /usr/bin/linuxdeploy \
    && chmod +x /usr/bin/linuxdeploy-plugin-qt \
    && chmod +x /usr/bin/appimagetool

RUN set -x \
    && groupadd -g 2000 keepassxc \
    && useradd -u 2000 -g keepassxc -d /keepassxc -s /bin/bash keepassxc

COPY docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["/keepassxc/src", "/keepassxc/out"]
WORKDIR /keepassxc
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bashx"]
