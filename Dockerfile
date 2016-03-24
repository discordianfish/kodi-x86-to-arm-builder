FROM ubuntu:14.04

ENV BUILD_DEPS git autoconf curl g++ zlib1g-dev libcurl4-openssl-dev gawk \
               gperf libtool autopoint swig default-jre unzip zip make

RUN apt-get -qy update \
    && apt-get install -qy $BUILD_DEPS $RUNTIME_DEPS \
    && curl -sL https://github.com/raspberrypi/tools/archive/master.tar.gz \
    | tar -C /usr/src -xzf - \
    && mv /usr/src/tools-master/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64 /opt \
    && mkdir -p /opt/bcm-rootfs/opt \
    && curl -sL https://github.com/raspberrypi/firmware/archive/master.tar.gz \
    | tar -C /usr/src -xzf - \
    && mv /usr/src/firmware-master/opt/vc /opt/bcm-rootfs/opt

RUN curl -sL https://github.com/xbmc/xbmc/archive/master.tar.gz | tar -C /usr/src -xzf - \
    && cd /usr/src/xbmc-master/tools/depends \
    && ./bootstrap \
    && PATH="$PATH:/opt/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin" \
    ./configure --host=arm-linux-gnueabihf --host=arm-linux-gnueabihf \
       --prefix=/opt/xbmc-bcm/xbmc-dbg \
       --with-toolchain=/usr/local/bcm-gcc/arm-bcm2708hardfp-linux-gnueabi/sysroot \
       --with-firmware=/opt/bcm-rootfs \
       --with-platform=raspberry-pi2 \
       --build=i686-linux \
    && make \
    && cd ../.. \
    && CONFIG_EXTRA="--with-platform=raspberry-pi2 \
       --enable-libcec --enable-player=omxplayer \
       --disable-x11 --disable-xrandr --disable-openmax \
       --disable-optical-drive --disable-dvdcss --disable-joystick \
       --disable-crystalhd --disable-vtbdecoder --disable-vaapi \
       --disable-vdpau --enable-alsa" \
       make -C tools/depends/target/xbmc \
    && make -j2 \
    && make install
