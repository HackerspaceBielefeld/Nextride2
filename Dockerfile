# ---- app bundle ----
FROM --platform=$BUILDPLATFORM debian:trixie-slim AS app-builder

ARG FLUTTER_VERSION=3.44.9

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        xz-utils \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 -b ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /opt/flutter

ENV PATH=/opt/flutter/bin:/root/.pub-cache/bin:$PATH \
    TAR_OPTIONS=--no-same-owner

RUN git config --global --add safe.directory '*' \
    && flutter config --no-analytics --no-cli-animations \
    && dart pub global activate flutterpi_tool

WORKDIR /src

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutterpi_tool build --release --arch=arm64 --cpu=pi3


# ---- flutter-pi ----
FROM --platform=$BUILDPLATFORM debian:trixie-slim AS flutter-pi-builder

ARG FLUTTER_PI_REPO=https://github.com/ardera/flutter-pi
ARG FLUTTER_PI_REF=8b86c52a004ec2ca7f98a65e5079219679002c61

RUN dpkg --add-architecture arm64 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        crossbuild-essential-arm64 \
        git \
        libdrm-dev:arm64 \
        libegl-dev:arm64 \
        libgbm-dev:arm64 \
        libgl-dev:arm64 \
        libgles-dev:arm64 \
        libinput-dev:arm64 \
        libsystemd-dev:arm64 \
        libudev-dev:arm64 \
        libxkbcommon-dev:arm64 \
        make \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN git init /flutter-pi \
    && cd /flutter-pi \
    && git remote add origin ${FLUTTER_PI_REPO} \
    && git fetch --depth 1 origin ${FLUTTER_PI_REF} \
    && git checkout FETCH_HEAD \
    && git submodule update --init --recursive --depth 1

RUN printf '%s\n' \
        'set(CMAKE_SYSTEM_NAME Linux)' \
        'set(CMAKE_SYSTEM_PROCESSOR aarch64)' \
        'set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)' \
        'set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)' \
        'set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu)' \
        'set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)' \
        > /toolchain.cmake

ENV PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig \
    PKG_CONFIG_SYSROOT_DIR=/

WORKDIR /flutter-pi/build

RUN cmake -DCMAKE_TOOLCHAIN_FILE=/toolchain.cmake -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_GSTREAMER_VIDEO_PLAYER_PLUGIN=OFF -DBUILD_GSTREAMER_AUDIO_PLAYER_PLUGIN=OFF .. \
    && make -j"$(nproc)" \
    && aarch64-linux-gnu-readelf -h flutter-pi | grep Machine


# ---- runtime ----
FROM --platform=linux/arm64 debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libatomic1 \
        libdrm2 \
        libegl1 \
        libevdev2 \
        libgbm1 \
        libgl1-mesa-dri \
        libgles2 \
        libinput10 \
        libmtdev1 \
        libsystemd0 \
        libudev1 \
        libwacom9 \
        libxkbcommon0 \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=app-builder /src/build/flutter-pi/pi3-64/ /app/
COPY --from=flutter-pi-builder /flutter-pi/build/flutter-pi /app/flutter-pi

WORKDIR /app

ENV TZ=Europe/Berlin

ENTRYPOINT ["/app/flutter-pi", "--release"]
CMD ["-r", "180", "/app"]
