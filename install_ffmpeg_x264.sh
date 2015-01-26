#!/bin/bash

## FFmpeg installation from git sources for Ubuntu
##
## Based on the guide at https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
##

echo "Server/headless (s) or Desktop (d) installation [s/d (default d)]?"
read answer
if [[ "$answer" == "d" || "$answer" == "D" || "$answer" == "" ]]; then
	SYSTYPE="desktop"
elif [[  "$answer" == "s" || "$answer" == "S" ]]; then
	SYSTYPE="server"
fi

echo "New installation (n) or updating a previous/older install (u) [n/u (default n)]?"
read answer
if [[ "$answer" == "n" || "$answer" == "N" || "$answer" == "" ]]; then
        INSTYPE="new"
elif [[  "$answer" == "u" || "$answer" == "U" ]]; then
        INSTYPE="update"
fi

# make ffmpeg_install dir in home directory for sources, etc.
DIR="/home/$USER/sources/ffmpeg_install"
if [[ ! -d "$DIR" ]]; then
	mkdir -p "$DIR"
fi
cd $DIR

#remove existing ffmpeg and x264 packages
#if [[ "$INSTYPE" == "new" ]]; then
#	sudo apt-get -y remove ffmpeg x264 libav-tools libvpx-dev libx264-dev yasm
#elif [[ "$INSTYPE" == "update" ]]; then
#	sudo apt-get -y remove ffmpeg x264 libx264-dev libvpx-dev
#fi

#update and install prereqs
sudo apt-get update

if [[ "$SYSTYPE" == "desktop" ]]; then
	sudo apt-get -y install autoconf automake build-essential git libass-dev libgpac-dev libmp3lame-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libx11-dev libxext-dev libxfixes-dev pkg-config texi2html zlib1g-dev
elif [[ "$SYSTYPE" == "server" ]]; then
	sudo apt-get -y install autoconf automake build-essential git libass-dev libgpac-dev libmp3lame-dev libtheora-dev libtool libvorbis-dev pkg-config texi2html zlib1g-dev
fi

CONFDIR="/home/$USER/sources/ffmpeg_build"

# YASM BLOCK
if [[ "$INSTYPE" == "new" ]]; then
	echo "Proceed with Yasm install? (required for new installations)"
	read answer
	if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
        	# install yasm
	        cd "$DIR"
        	if [[ -d "yasm" ]]; then
			rm -rfv yasm
	        fi
		wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
		tar xzvf yasm-1.3.0.tar.gz
		cd yasm-1.3.0
		./configure --prefix="$CONFDIR" --bindir="$HOME/bin"
		make
		make install
		make distclean
		. ~/.profile
	fi
fi
# END YASM

# X264 BLOCK
if [[ "$INSTYPE" == "new" ]]; then
	echo "Proceed with x264 install? (required)"
	read answer
	if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
		# install x264
		cd "$DIR"
		if [[ -d "x264" ]]; then
			rm -rfv x264
		fi
		git clone --depth 1 git://git.videolan.org/x264.git
		cd x264
		./configure --prefix="$CONFDIR" --bindir="$HOME/bin" --enable-static
		make
		make install
		make distclean
	fi
elif [[ "$INSTYPE" == "update" ]]; then
	cd "$DIR/x264"
	make distclean
	git pull
	./configure --enable-static
	make
	sudo checkinstall --pkgname=x264 --pkgversion="3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes --fstrans=no --default
fi
# END X264

# FDK-AAC BLOCK
if [[ "$INSTYPE" == "new" ]]; then
	echo "Proceed with fdk-aac? (required)"
	read answer
	if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
		# install fdk-aac
		cd "$DIR"
		if [[ -d "fdk-aac" ]]; then
			rm -rfv fdk-aac
		fi
		git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
		cd fdk-aac
		autoreconf -fiv
		./configure --prefix="$CONFDIR" --disable-shared
		make
		make install
		make distclean
	fi
elif [[ "$INSTYPE" == "update" ]]; then
	cd "$DIR/fdk-aac"
	make distclean
	git pull
	./configure --disable-shared
	make
	sudo checkinstall --pkgname=fdk-aac --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
fi
#END FDK-AAC

# LIBVPX BLOCK
if [[ "$INSTYPE" == "new" ]]; then
	echo "Proceed with libvpx? (required)"
	read answer
	if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
		# install libvpx
		cd "$DIR"
		if [[ -d "libvpx" ]]; then
                	rm -rfv libvpx
	        fi
		git clone http://git.chromium.org/webm/libvpx.git
		cd libvpx
		./configure --prefix="$CONFDIR" --disable-examples
		make
		make install
		make clean
	fi
elif [[ "$INSTYPE" == "update" ]]; then
	cd "$DIR/libvpx"
	make clean
	git pull
	./configure --disable-examples --disable-unit-tests
	make
	sudo checkinstall --pkgname=libvpx --pkgversion="1:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
fi
# END LIBVPX

# OPUS BLOCK
#if [[ "$INSTYPE" == "new" ]]; then
#	echo "Proceed with Opus? (optional)"
#	read answer
#	if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
		# install opus audio support
#	        cd "$DIR"
#		if [[ -d "opus" ]]; then
#                	rm -rfv opus
#	        fi
#		git clone --depth 1 git://git.xiph.org/opus.git
#		cd opus
#		./autogen.sh
#		./configure --disable-shared
#		make
#		sudo checkinstall --pkgname=libopus --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
#	fi
#elif [[ "$INSTYPE" == "update" ]]; then
#	cd "$DIR/opus"
#	make distclean
#	git pull
#	./configure --disable-shared
#	make
#	sudo checkinstall --pkgname=libopus --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
#fi
# END OPUS

# FFMPEG BLOCK
if [[ "$INSTYPE" == "new" ]]; then
	echo "Proceed with ffmpeg? (required, duh)"
	read answer
	if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
		# install ffmpeg
		cd "$DIR"
		if [[ -d "ffmpeg" ]]; then
        	        rm -rfv ffmpeg
	        fi
		git clone --depth 1 git://source.ffmpeg.org/ffmpeg
		cd ffmpeg
		PKG_CONFIG_PATH="$CONFDIR/lib/pkgconfig"
		export PKG_CONFIG_PATH
		if [[ "$SYSTYPE" == "desktop" ]]; then
			./configure --prefix="$CONFDIR" --extra-cflags="-I$CONFDIR/include" --extra-ldflags="-L$CONFDIR/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-nonfree --enable-x11grab
		elif [[ "$SYSTYPE" == "server" ]]; then
      ./configure --prefix="$CONFDIR" --extra-cflags="-I$CONFDIR/include" --extra-ldflags="-L$CONFDIR/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-nonfree
		fi
		make
		make install
		make distclean
		hash -r
	fi
elif [[ "$INSTYPE" == "update" ]]; then
	cd "$DIR/ffmpeg"
	make distclean
	git pull
	if [[ "$SYSTYPE" == "desktop" ]]; then
		./configure --enable-gpl --enable-libass --enable-libfaac --enable-libfdk-aac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libspeex --enable-librtmp --enable-libtheora --enable-libvorbis --enable-libvpx --enable-x11grab --enable-libx264 --enable-nonfree --enable-version3
	elif [[ "$SYSTYPE" == "server" ]]; then
		./configure --enable-gpl --enable-libass --enable-libfaac --enable-libfdk-aac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libspeex --enable-librtmp --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-nonfree --enable-version3
	fi
	make
	sudo checkinstall --pkgname=ffmpeg --pkgversion="7:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
fi
# END FFMPEG

# LAVF BLOCK
if [[ "$INSTYPE" == "new" ]]; then
	echo "Proceed with lavf (optional)?"
	read answer
	if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
		# add lavf support to x264
		cd $DIR/x264
		make distclean
		./configure --enable-static --enable-strip
		make
		sudo checkinstall --pkgname=x264 --pkgversion="3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes --fstrans=no --default
	fi
fi
# END LAVF

# QT-FASTSTART BLOCK
if [[ "$INSTYPE" == "new" ]]; then
	echo "Proceed with qt-faststart (optional)?"
	read answer
	if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
		# install qt-faststart
		cd $DIR/ffmpeg
		make tools/qt-faststart
		sudo checkinstall --pkgname=qt-faststart --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default install -Dm755 tools/qt-faststart /usr/local/bin/qt-faststart
	fi
fi
# END QT-FASTSTART
