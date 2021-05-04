# Docker File for pick place demo
ARG HOME_DIR=/home/jovian/Desktop/RoboticsAcademyDocker/home

FROM ros:melodic

RUN apt-get update && \
    apt-get install python-rosdep python-rosinstall python-rosinstall-generator \
    python-wstool build-essential ros-melodic-catkin python-catkin-tools -y

# Install moveit
RUN apt-get update && \
    apt-get install ros-melodic-moveit ros-melodic-ros-control \
                     ros-melodic-ros-controllers -y 

#Mount Persistent Home dir
VOLUME HOME_DIR:/root/

# Install Industrial Robot package
RUN apt-get install git -y && \
    mkdir -p ~/catkin_ws/src && cd ~/catkin_ws/src && \
    git clone https://github.com/Jovian-Dsouza/IndustrialRobots -b melodic_devel 


RUN rosdep update 
RUN cd ~/catkin_ws && \
    rosdep install --from-paths . --ignore-src --rosdistro melodic -y 


RUN echo 'source ~/catkin_ws/devel/setup.bash' >> ~/.bashrc && \
    echo 'export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:~/catkin_ws/src/IndustrialRobots/assets/models' >> ~/.bashrc

