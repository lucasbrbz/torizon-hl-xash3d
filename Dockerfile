# BUILD SDK --------------------------------------------------------------------
FROM torizon/cross-toolchain-arm64-imx8:4 AS build-sdk

RUN dpkg --add-architecture arm64

RUN apt-get -q -y update && \
    apt-get -q -y install --no-install-recommends \
    make \
    cmake \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY hlsdk-portable/ .

# Compile using the cross-compiler provided by the base image
RUN CC=aarch64-linux-gnu-gcc cmake -S . -B build-torizon -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build-torizon -j$(nproc)

# BUILD XASH -------------------------------------------------------------------
FROM torizon/cross-toolchain-arm64-imx8:4 AS build-xash

RUN dpkg --add-architecture arm64

RUN apt-get -q -y update && \
    apt-get -q -y install --no-install-recommends \
    git \
    build-essential \
    python3 \
    libsdl2-dev \
    libfreetype6-dev \
    libopus-dev \
    libbz2-dev \
    libvorbis-dev \
    libopusfile-dev \
    libogg-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY xash3d-fwgs/ .

# Provide the names waf expects
RUN ln -sf /usr/bin/aarch64-linux-gnu-gcc /usr/local/bin/aarch64-linux-gnu-cc && \
    ln -sf /usr/bin/aarch64-linux-gnu-g++ /usr/local/bin/aarch64-linux-gnu-c++

RUN ./waf configure
RUN ./waf build -j$(nproc)
RUN ./waf install --destdir=/app/build-torizon

# DEPLOY -----------------------------------------------------------------------
FROM torizon/wayland-base-imx8:4 AS deploy

RUN apt-get update && apt-get install -y --no-install-recommends \
    imx-gpu-viv-wayland \
    libsdl2-2.0-0 \
    libbz2-1.0 \
    libopus0 \
    libopusfile0 \
    libvorbis0a \
    libvorbisfile3 \
    libogg0 \
    libfreetype6 \
    zlib1g \
    libpng16-16 \
    libbrotli1 \
    libxkbcommon0 \
    libasound2 \
    libpulse0 \
    libsamplerate0 \
    libdrm2 \
    libwayland-client0 \
    libwayland-egl1 \
    libwayland-cursor0 \
    libwayland-server0 \
    libdecor-0-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/xash

# Copy the game assets
COPY valve/ /opt/xash/valve/

# Copy the Xash runtime produced by waf install
COPY --from=build-xash /app/build-torizon/ /opt/xash/

# Copy HLSDK server/client libraries into the places Xash expects
COPY --from=build-sdk /app/build-torizon/dlls/hl_arm64.so /opt/xash/valve/dlls/hl_arm64.so
COPY --from=build-sdk /app/build-torizon/cl_dll/client_arm64.so /opt/xash/valve/cl_dlls/client_arm64.so

ENTRYPOINT ["/opt/xash/xash3d", "-game", "valve"]
