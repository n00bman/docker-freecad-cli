FROM ubuntu:21.04
MAINTAINER Andrew Yaborov <avyaborov@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt install -y --no-install-recommends software-properties-common gpg-agent \
    && add-apt-repository -y ppa:freecad-maintainers/freecad-stable

# Main
RUN \
    pack_build="git \
                wget \
                build-essential \
                cmake \
                libtool \
                libboost-dev \
                libboost-date-time-dev \
                libboost-filesystem-dev \
                libboost-graph-dev \
                libboost-iostreams-dev \
                libboost-program-options-dev \
                libboost-python-dev \
                libboost-regex-dev \
                libboost-serialization-dev \
                libboost-thread-dev \
                libocct-data-exchange-dev \
                libocct-draw-dev \
                libocct-foundation-dev \
                libocct-modeling-algorithms-dev \
                libocct-modeling-data-dev \
                libocct-ocaf-dev \
                libocct-visualization-dev \
                occt-draw \
                libeigen3-dev \
                libgts-bin \
                libgts-dev \
                libkdtree++-dev \
                libmedc-dev \
                libopencv-dev \
                libproj-dev \
                libvtk7-dev \
                libxerces-c-dev \
                libzipios++-dev \
                libode-dev \
                libfreetype6 \
                libfreetype6-dev \
                netgen-headers \
                netgen \
                libmetis-dev \
                gmsh " \
    && apt install -y --no-install-recommends $pack_build

# Phyton 3 & QT5
RUN \
    pack_build="qtbase5-dev \
    		qtchooser \
    		qt5-qmake \
    		qtbase5-dev-tools \
		libqt5opengl5-dev \
		libqt5svg5-dev \
		libqt5webkit5-dev \
		libqt5xmlpatterns5-dev \
		libqt5x11extras5-dev \
		libpyside2-dev \
		libshiboken2-dev \
		pyside2-tools \
		pyqt5-dev-tools \
		python3 \
                python3-dev \
                python3-distutils \
		python3-matplotlib \
		python3-ply \
		python3-pyside2.qtcore \
		python3-pyside2.qtsvg \
		python3-pyside2.qtwidgets \
		python3-pyside2.qtnetwork \
		python3-testresources \
		" \
    && apt install -y --no-install-recommends $pack_build

RUN git clone https://github.com/FreeCAD/FreeCAD.git freecad-source && mkdir freecad-build

WORKDIR freecad-build

RUN cmake ../freecad-source \
    -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")  \
    -DPYTHON_LIBRARY=$(python3 -c "import distutils.sysconfig as sysconfig; import os; print(os.path.join(sysconfig.get_config_var('LIBDIR'), sysconfig.get_config_var('LDLIBRARY')))") \
    -DBUILD_QT5=ON \
    -DBUILD_GUI=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_FEM_NETGEN=ON \
    && make -j$(nproc --ignore=1) && make install && rm -rf /freecad-source /freecad-build

# Install GUI libraries that require to import Draft, Arch modules.
# RUN apt install -y python3-pip && pip3 install PySide2 && pip3 install six
# RUN ln -s /usr/local/lib/python3.9/dist-packages/PySide2 /usr/local/lib/python3.9/dist-packages/PySide

# Fixed import MeshPart module due to missing libnglib.so
# https://bugs.launchpad.net/ubuntu/+source/freecad/+bug/1866914
RUN echo "/usr/lib/x86_64-linux-gnu/netgen" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf
RUN ldconfig

# Make Python already know all FreeCAD modules / workbenches.
ENV FREECAD_STARTUP_FILE /.startup.py
RUN echo "import FreeCAD\n" > ${FREECAD_STARTUP_FILE}
ENV PYTHONSTARTUP ${FREECAD_STARTUP_FILE}

# Clean
RUN apt-get clean \
    && rm /var/lib/apt/lists/* \
          /usr/share/doc/* \
          /usr/share/locale/* \
          /usr/share/man/* \
          /usr/share/info/* -fR
