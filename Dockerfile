FROM abernix/meteord:base


CMD         ["--help"]
ENTRYPOINT  ["ffmpeg"]
WORKDIR     /tmp/workdir


ENV         FFMPEG_VERSION=2.8.12     \
            FDKAAC_VERSION=0.1.5      \
            LAME_VERSION=3.99.5       \
            LIBASS_VERSION=0.13.7     \  
            OGG_VERSION=1.3.2         \
            OPENCOREAMR_VERSION=0.1.4 \
            OPUS_VERSION=1.2          \
            THEORA_VERSION=1.1.1      \
            VORBIS_VERSION=1.3.5      \
            VPX_VERSION=1.6.1         \
            X264_VERSION=20170226-2245-stable \
            X265_VERSION=2.3          \
            XVID_VERSION=1.3.4        \
            FREETYPE_VERSION=2.5.5    \
            FRIBIDI_VERSION=0.19.7    \
            FONTCONFIG_VERSION=2.12.4 \
            LIBVIDSTAB_VERSION=1.1.0  \
            PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
            SRC=/usr/local


ARG         OGG_SHA256SUM="e19ee34711d7af328cb26287f4137e70630e7261b17cbe3cd41011d73a654692  libogg-1.3.2.tar.gz"
ARG         OPUS_SHA256SUM="77db45a87b51578fbc49555ef1b10926179861d854eb2613207dc79d9ec0a9a9  opus-1.2.tar.gz"
ARG         VORBIS_SHA256SUM="6efbcecdd3e5dfbf090341b485da9d176eb250d893e3eb378c428a2db38301ce  libvorbis-1.3.5.tar.gz"
ARG         THEORA_SHA256SUM="40952956c47811928d1e7922cda3bc1f427eb75680c3c37249c91e949054916b  libtheora-1.1.1.tar.gz"
ARG         XVID_SHA256SUM="4e9fd62728885855bc5007fe1be58df42e5e274497591fec37249e1052ae316f  xvidcore-1.3.4.tar.gz"
ARG         FREETYPE_SHA256SUM="5d03dd76c2171a7601e9ce10551d52d4471cf92cd205948e60289251daddffa8  freetype-2.5.5.tar.gz"
ARG         LIBVIDSTAB_SHA256SUM="14d2a053e56edad4f397be0cb3ef8eb1ec3150404ce99a426c4eb641861dc0bb  v1.1.0.tar.gz"
ARG         LIBASS_SHA256SUM="8fadf294bf701300d4605e6f1d92929304187fca4b8d8a47889315526adbafd7  0.13.7.tar.gz"
ARG         FRIBIDI_SHA256SUM="08222a6212bbc2276a2d55c3bf370109ae4a35b689acbc66571ad2a670595a8e  fribidi-0.19.7.tar.bz2"

ARG         LD_LIBRARY_PATH=${SRC}/lib

RUN     buildDeps="autoconf \
                   automake \
                   bzip2 \
                   cmake \
                   expat-devel \
                   gcc \
                   gcc-c++ \
                   git \
                   gperf \
                   libtool \
                   make \
                   nasm \
                   perl \
                   openssl-devel \
                   tar \
                   yasm \
                   which \
                   zlib-devel" && \
        export MAKEFLAGS="-j$(($(nproc) + 1))" && \
        echo "${SRC}/lib" > /etc/ld.so.conf.d/libc.conf && \
        yum --enablerepo=extras install -y epel-release libgomp expat && \
        yum install -y ${buildDeps} libgomp1 && \
#RUN  \
## opencore-amr https://sourceforge.net/projects/opencore-amr/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sL https://downloads.sf.net/project/opencore-amr/opencore-amr/opencore-amr-${OPENCOREAMR_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --enable-shared --datadir=${DIR} && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## x264 http://www.videolan.org/developers/x264.html
       DIR=$(mktemp -d) && cd ${DIR} && \
       curl -sL https://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 | \
       tar -jx --strip-components=1 && \
       ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --enable-pic --enable-shared --disable-cli && \
       make && \
       make install && \
       rm -rf ${DIR} && \
#RUN  \
## x265 http://x265.org/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sL https://download.videolan.org/pub/videolan/x265/x265_${X265_VERSION}.tar.gz  | \
        tar -zx && \
        cd x265_${X265_VERSION}/build/linux && \
        ./multilib.sh && \
        make -C 8bit install && \
        rm -rf ${DIR} && \
#RUN  \
## libogg https://www.xiph.org/ogg/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO http://downloads.xiph.org/releases/ogg/libogg-${OGG_VERSION}.tar.gz && \
        echo ${OGG_SHA256SUM} | sha256sum --check && \
        tar -zx --strip-components=1 -f libogg-${OGG_VERSION}.tar.gz && \
        ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --disable-static --datarootdir=${DIR} && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## libopus https://www.opus-codec.org/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz && \
        echo ${OPUS_SHA256SUM} | sha256sum --check && \
        tar -zx --strip-components=1 -f opus-${OPUS_VERSION}.tar.gz && \
        autoreconf -fiv && \
        ./configure --prefix="${SRC}" --disable-static --datadir="${DIR}" && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## libvorbis https://xiph.org/vorbis/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO http://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS_VERSION}.tar.gz && \
        echo ${VORBIS_SHA256SUM} | sha256sum --check && \
        tar -zx --strip-components=1 -f libvorbis-${VORBIS_VERSION}.tar.gz && \
        ./configure --prefix="${SRC}" --with-ogg="${SRC}" --bindir="${SRC}/bin" \
        --disable-static --datadir="${DIR}" && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## libtheora http://www.theora.org/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO http://downloads.xiph.org/releases/theora/libtheora-${THEORA_VERSION}.tar.gz && \
        echo ${THEORA_SHA256SUM} | sha256sum --check && \
        tar -zx --strip-components=1 -f libtheora-${THEORA_VERSION}.tar.gz && \
        ./configure --prefix="${SRC}" --with-ogg="${SRC}" --bindir="${SRC}/bin" \
        --disable-static --datadir="${DIR}" && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## libvpx https://www.webmproject.org/code/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sL https://codeload.github.com/webmproject/libvpx/tar.gz/v${VPX_VERSION} | \
        tar -zx --strip-components=1 && \
        ./configure --prefix="${SRC}" --enable-vp8 --enable-vp9 --enable-pic --disable-debug --disable-examples --disable-docs --disable-install-bins --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## libmp3lame http://lame.sourceforge.net/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sL https://downloads.sf.net/project/lame/lame/${LAME_VERSION%.*}/lame-${LAME_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --disable-static --enable-nasm --datarootdir="${DIR}" && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## xvid https://www.xvid.com/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO http://downloads.xvid.org/downloads/xvidcore-${XVID_VERSION}.tar.gz && \
        echo ${XVID_SHA256SUM} | sha256sum --check && \
        tar -zx -f xvidcore-${XVID_VERSION}.tar.gz && \
        cd xvidcore/build/generic && \
        ./configure --prefix="${SRC}" --bindir="${SRC}/bin" --datadir="${DIR}" --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## fdk-aac https://github.com/mstorsjo/fdk-aac
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sL https://github.com/mstorsjo/fdk-aac/archive/v${FDKAAC_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        autoreconf -fiv && \
        ./configure --prefix="${SRC}" --disable-static --datadir="${DIR}" && \
        make && \
        make install && \
        make distclean && \
        rm -rf ${DIR} && \
#RUN  \
## freetype https://www.freetype.org/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO http://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz && \
        echo ${FREETYPE_SHA256SUM} | sha256sum --check && \
        tar -zx --strip-components=1 -f freetype-${FREETYPE_VERSION}.tar.gz && \
        ./configure --prefix="${SRC}" --disable-static --enable-shared && \
        make && \
        make install && \
        make distclean && \
        rm -rf ${DIR} && \
#RUN  \
## libvstab https://github.com/georgmartius/vid.stab
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO https://github.com/georgmartius/vid.stab/archive/v${LIBVIDSTAB_VERSION}.tar.gz &&\
        echo ${LIBVIDSTAB_SHA256SUM} | sha256sum --check && \
        tar -zx --strip-components=1 -f v${LIBVIDSTAB_VERSION}.tar.gz && \
        cmake -DCMAKE_INSTALL_PREFIX="${SRC}" . && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## fridibi https://www.fribidi.org/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO http://fribidi.org/download/fribidi-${FRIBIDI_VERSION}.tar.bz2 &&\
        echo ${FRIBIDI_SHA256SUM} | sha256sum --check && \
        tar -jx --strip-components=1 -f fribidi-${FRIBIDI_VERSION}.tar.bz2 && \
        ./configure -prefix="${SRC}" --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## fontconfig https://www.freedesktop.org/wiki/Software/fontconfig/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.bz2 &&\
        tar -jx --strip-components=1 -f fontconfig-${FONTCONFIG_VERSION}.tar.bz2 && \
        ./configure -prefix="${SRC}" --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## libass https://github.com/libass/libass
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO https://github.com/libass/libass/archive/${LIBASS_VERSION}.tar.gz &&\
        echo ${LIBASS_SHA256SUM} | sha256sum --check && \
        tar -zx --strip-components=1 -f ${LIBASS_VERSION}.tar.gz && \
        ./autogen.sh && \
        ./configure -prefix="${SRC}" --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR} && \
#RUN  \
## ffmpeg https://ffmpeg.org/
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f ffmpeg-${FFMPEG_VERSION}.tar.gz && \
        ./configure \
        --bindir="${SRC}/bin" \
        --disable-debug \
        --disable-doc \
        --disable-ffplay \
        --disable-static \
        --enable-avresample \
        --enable-gpl \
        --enable-libass \
        --enable-libopencore-amrnb \
        --enable-libopencore-amrwb \
        --enable-libfdk_aac \
        --enable-libfreetype \
        --enable-libvidstab \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libxvid \
        --enable-nonfree \
        --enable-openssl \
        --enable-postproc \
        --enable-shared \
        --enable-small \
        --enable-version3 \
        --extra-cflags="-I${SRC}/include" \
        --extra-ldflags="-L${SRC}/lib" \
        --extra-libs=-ldl \
        --prefix="${SRC}" && \
        make && \
        make install && \
        make distclean && \
        hash -r && \
        cd tools && \
        make qt-faststart && \
        cp qt-faststart ${SRC}/bin && \
        rm -rf ${DIR} && \

# cleanup
        cd && \
        yum history -y undo last && yum clean all && \
        rm -rf /var/lib/yum/* && \
        ffmpeg -buildconf