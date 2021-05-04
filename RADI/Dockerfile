#FROM nvidia/cudagl:10.0-devel-ubuntu18.04
FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu18.04

ARG SOURCEFORGE=https://sourceforge.net/projects
ARG TURBOVNC_VERSION=2.1.2
ARG VIRTUALGL_VERSION=2.5.2
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG NOVNC_VERSION=1.0.0
ARG LIBARMADILLO_VERSION=8

#---------------------------------------------------------------------
# Install Linux stuff
#---------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl wget less sudo lsof git net-tools nano psmisc xz-utils nemo vim net-tools iputils-ping traceroute htop \
    lubuntu-core xterm terminator zenity make cmake gcc libc6-dev \
    x11-xkb-utils xauth xfonts-base xkb-data \
    mesa-utils xvfb libgl1-mesa-dri libgl1-mesa-glx libglib2.0-0 libxext6 libsm6 libxrender1 \
    libglu1 libglu1:i386 libxv1 libxv1:i386 \
    python python-numpy libpython-dev libsuitesparse-dev libgtest-dev build-essential \
    libeigen3-dev libsdl1.2-dev libignition-math2-dev libarmadillo-dev libarmadillo${LIBARMADILLO_VERSION} libsdl-image1.2-dev libsdl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

#---------------------------------------------------------------------
# Install gtest
#---------------------------------------------------------------------
RUN cd /usr/src/gtest \
	&& mkdir build && cd build \
	&& cmake .. && make -j$(nproc) \
	&& cp *.a /usr/lib \
	&& cd .. && rm -rf build

#---------------------------------------------------------------------
# Install VirtualGL and TurboVNC
#---------------------------------------------------------------------
RUN cd /tmp && \
    curl -fsSL -O ${SOURCEFORGE}/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
    -O ${SOURCEFORGE}/libjpeg-turbo/files/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb \
    -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
    -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver
ENV PATH ${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin

#---------------------------------------------------------------------
# Install noVNC
#---------------------------------------------------------------------
RUN curl -fsSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzf - -C /opt && \
    curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/noVNC-${NOVNC_VERSION} /opt/noVNC && \
    chmod -R a+w /opt/noVNC && \
    mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify && \
    cd /opt/websockify && make && \
    cd /opt/noVNC/utils && \
    ln -s /opt/websockify
COPY requirements/xorg.conf /etc/X11/xorg.conf
COPY requirements/index.html /opt/noVNC/index.html

#---------------------------------------------------------------------
#Fix locale (UTF8) issue https://askubuntu.com/questions/162391/how-do-i-fix-my-locale-issue
#---------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \ 
	apt-get install -y locales && \
	locale-gen "en_US.UTF-8" && \
	apt-get clean

#---------------------------------------------------------------------
# PX4
#---------------------------------------------------------------------
ENV DEBIAN_FRONTEND noninteractive

RUN apt remove modemmanager
RUN apt-get update && apt-get -y --quiet --no-install-recommends install \
		bzip2 \
		ca-certificates \
		ccache \
		cmake \
		cppcheck \
		curl \
		dirmngr \
		doxygen \
		exiftool \
		file \
		g++ \
		gcc \
		gdb \
		genromfs \
		git \
		gnupg \
		gosu \
		lcov \
		libfreetype6-dev \
		libgtest-dev \
		libpng-dev \
		libssl-dev \
		lsb-release \
		make \
		ninja-build \
		openjdk-8-jdk \
		openjdk-8-jre \
		openssh-client \
		pkg-config \
		python3-dev \
		python3-pip \
		qtcreator \
		rsync \
		shellcheck \
		tzdata \
		unzip \
		valgrind \
		wget \
		xsltproc \
		zip \
	&& apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN which xxd || apt install xxd -y || apt install vim-common --no-install-recommends -y

# Install Python 3 pip build dependencies first.
RUN pip3 install wheel setuptools

# Python 3 dependencies installed by pip
RUN pip3 install argparse argcomplete coverage cerberus empy jinja2 \
		matplotlib==3.0.* numpy nunavut packaging pkgconfig pyros-genmsg pyulog \
		pyyaml requests serial six toml psutil pyulog wheel

# manual ccache setup
RUN ln -sf /usr/bin/ccache /usr/lib/ccache/cc \
	&& ln -sf /usr/bin/ccache /usr/lib/ccache/c++

# astyle v3.1
RUN wget -q https://downloads.sourceforge.net/project/astyle/astyle/astyle%203.1/astyle_3.1_linux.tar.gz -O /tmp/astyle.tar.gz \
	&& cd /tmp && tar zxf astyle.tar.gz && cd astyle/src \
	&& make -f ../build/gcc/Makefile -j$(nproc) && cp bin/astyle /usr/local/bin \
	&& rm -rf /tmp/*

# Gradle (Required to build Fast-RTPS-Gen)
RUN wget -q "https://services.gradle.org/distributions/gradle-6.3-rc-4-bin.zip" -O /tmp/gradle-6.3-rc-4-bin.zip \
	&& mkdir /opt/gradle \
	&& cd /tmp \
	&& unzip -d /opt/gradle gradle-6.3-rc-4-bin.zip \
	&& rm -rf /tmp/*

ENV PATH "/opt/gradle/gradle-6.3-rc-4/bin:$PATH"

# Fast-RTPS 1.8.2
RUN git clone --recursive https://github.com/eProsima/Fast-DDS.git -b v1.8.2 /tmp/FastRTPS-1.8.2 \
	&& cd /tmp/FastRTPS-1.8.2 \
	&& mkdir build && cd build \
	&& cmake -DTHIRDPARTY=ON -DSECURITY=ON .. \
	&& cmake --build . --target install -- -j $(nproc) \
	&& rm -rf /tmp/*

# Fast-RTPS-Gen 1.0.4
RUN git clone --recursive https://github.com/eProsima/Fast-DDS-Gen.git -b v1.0.4 /tmp/Fast-RTPS-Gen-1.0.4 \
	&& cd /tmp/Fast-RTPS-Gen-1.0.4 \
	&& gradle assemble \
	&& gradle install \
	&& rm -rf /tmp/*

#---------------------------------------------------------------------
# Install ROS and ROS packages
#---------------------------------------------------------------------
ENV ROS_DISTRO melodic
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
	&& sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' \
	&& sh -c 'echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-shadow.list' \
	&& apt-get update \
	&& apt-get -y --quiet --no-install-recommends install \
		ros-$ROS_DISTRO-desktop-full \
		geographiclib-tools \
		libeigen3-dev \
		libgeographic-dev \
		libopencv-dev \
		libyaml-cpp-dev \
		python-pip \
		python-tk \
		ros-$ROS_DISTRO-gazebo-ros-pkgs \
		ros-$ROS_DISTRO-jderobot-drones \
		ros-$ROS_DISTRO-mav-msgs \
		ros-$ROS_DISTRO-mavlink \
		ros-$ROS_DISTRO-mavros \
		ros-$ROS_DISTRO-mavros-extras \
		ros-$ROS_DISTRO-octomap \
		ros-$ROS_DISTRO-octomap-msgs \
		ros-$ROS_DISTRO-pcl-conversions \
		ros-$ROS_DISTRO-pcl-msgs \
		ros-$ROS_DISTRO-pcl-ros \
		ros-$ROS_DISTRO-ros-base \
		ros-$ROS_DISTRO-rostest \
		ros-$ROS_DISTRO-rosunit \
		ros-$ROS_DISTRO-xacro \
	&& geographiclib-get-geoids egm96-5 \
	&& apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# catkin build tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python-pyproj \
    python-catkin-tools \
    && apt-get clean
    
# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && rosdep update 

# Install everything again for Python 2 because we could not get Firmware
# to compile using catkin without it.
ENV PIP_DEFAULT_TIMEOUT=1000
RUN pip install wheel setuptools
RUN pip install argcomplete argparse catkin_pkg catkin-tools cerberus coverage 
RUN pip install packaging pyros-genmsg pyulog==0.8.* pyyaml requests rosdep rospkg serial six toml
RUN pip install empy jinja2 matplotlib==2.2.* numpy pkgconfig px4tools pygments 
RUN pip install pymavlink 

#---------------------------------------------------------------------
# Install PX4 from source
#---------------------------------------------------------------------
# RUN apt-get update
# RUN apt upgrade -y --quiet --no-install-recommends libignition-math2
# RUN git clone --recursive https://github.com/PX4/Firmware.git -b v1.11.3 \
# 	&& cd /Firmware \
# 	&& DONT_RUN=1 make px4_sitl_default gazebo

#---------------------------------------------------------------------
# Get the Custom Robot Repository
# and set the environment variables
#---------------------------------------------------------------------
RUN mkdir -p /opt/jderobot && cd /opt/jderobot && \ 
    git clone https://github.com/JdeRobot/CustomRobots.git \
    && cd CustomRobots && git checkout melodic-devel && \ 
    git pull origin melodic-devel
    
#---------------------------------------------------------------------
# Setting environment variables
#---------------------------------------------------------------------
ENV GAZEBO_RESOURCE_PATH "$GAZEBO_RESOURCE_PATH:/usr/share/gazebo-9:/RoboticsAcademy/exercises/follow_line/web-template/launch"
ENV GAZEBO_PLUGIN_PATH "$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-9/plugins:/Firmware/build/px4_sitl_default/build_gazebo"
ENV GAZEBO_MODEL_PATH "$GAZEBO_MODEL_PATH:/usr/share/gazebo-9/models:/opt/jderobot/CustomRobots/f1:/opt/jderobot/CustomRobots/roomba_robot:/opt/jderobot/CustomRobots/3d_reconstruction:/Firmware/Tools/sitl_gazebo/models:/opt/ros/melodic/share/drone_assets/models:/opt/ros/melodic/share/drone_assets/urdf"
ENV LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/gazebo-9/plugins:/Firmware/build/px4_sitl_default/build_gazebo"

# Console
RUN apt-get -y install xterm

# RoboticsAcademy
RUN git clone https://github.com/JdeRobot/RoboticsAcademy.git && cd RoboticsAcademy && git pull origin master
RUN rsync -a --exclude 'ace-builds' /RoboticsAcademy/exercises/static/exercises/* /RoboticsAcademy/exercises


# Certain Dependencies for Exercises
RUN apt-get update && \ 
	# Vacuum Cleaner Exercise
	apt-get -y --quiet install ros-melodic-kobuki-msgs  && \
	# Drone-cat-mouse
   	apt-get -y --quiet --no-install-recommends install xmlstarlet && \
	# Follow Turtlebot exercise
	apt-get -y --quiet --no-install-recommends install \
		ros-$ROS_DISTRO-turtlebot3-description
	
# Finish
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

# django to serve the exercises
RUN pip3 install django
COPY start.sh /start.sh
RUN chmod 755 /start.sh

#---------------------------------------------------------------------
# Copy Required scripts and Certificates
#---------------------------------------------------------------------
COPY ./requirements/self.pem /root/self.pem
COPY requirements/launch.sh /opt/noVNC/utils/launch.sh
COPY requirements/start_desktop.sh /usr/local/bin/start_desktop.sh

# Start setups for TurboVNC
RUN mkdir -p /root/.vnc
COPY ./requirements/xstartup.turbovnc /root/.vnc/xstartup.turbovnc
RUN chmod a+x /root/.vnc/xstartup.turbovnc

# Precede bash on all new terminator shells with vglrun so that 3d graphics apps will use the GPU
# RUN perl -pi -e 's/^Exec=terminator$/Exec=terminator -e "vglrun bash"/g' /usr/share/applications/terminator.desktop

# Expose whatever port NoVNC will serve from. In our case it will be 40001, see ./start_desktop.sh
EXPOSE 40001
# DISPLAY :1 for NoVNC
ENV DISPLAY :1 

EXPOSE 2303
EXPOSE 1905
EXPOSE 8080
EXPOSE 7681
EXPOSE 8765
EXPOSE 1108
# Port by WebRtc
EXPOSE 1831
# Port for noVNC
EXPOSE 6080

# Uncomment for autostart of the VNC server
# CMD /usr/local/bin/start_desktop.sh
CMD /bin/bash
