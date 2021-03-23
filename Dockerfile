
FROM osrf/ros:melodic-desktop

SHELL ["/bin/bash", "-c"]

RUN useradd -ms /bin/bash husarion && usermod -aG sudo husarion && echo 'husarion     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ARG cc
ARG cxx

# Set the preferred C/C++ compiler toolchain, if given (otherwise default).
ENV CC=$cc
ENV CXX=$cxx

RUN echo dupadfg

RUN ls


#COPY --chown=husarion /github/workspace/ /home/husarion/cartographer_workspace/
#RUN cd workspace && ls
# This base image doesn't ship with sudo, apt-utils. tzdata is installed here to avoid hanging later
# when it would wait for user input. 
#RUN apt-get update && apt-get install -y sudo apt-utils tzdata && rm -rf /var/lib/apt/lists/*

ENV cartographer_prefix=cartographer

COPY $cartographer_prefix/scripts/install_debs_cmake.sh cartographer/scripts/
RUN $cartographer_prefix/scripts/install_debs_cmake.sh && rm -rf /var/lib/apt/lists/*
COPY $cartographer_prefix/scripts/install_abseil.sh cartographer/scripts/
RUN cartographer/scripts/install_abseil.sh && rm -rf /var/lib/apt/lists/*
COPY $cartographer_prefix/scripts/install_proto3.sh cartographer/scripts/
RUN cartographer/scripts/install_proto3.sh && rm -rf protobuf
COPY $cartographer_prefix/scripts/install_grpc.sh cartographer/scripts/
RUN cartographer/scripts/install_grpc.sh && rm -rf grpc
COPY $cartographer_prefix/scripts/install_async_grpc.sh cartographer/scripts/
RUN cartographer/scripts/install_async_grpc.sh && rm -rf async_grpc
COPY $cartographer_prefix/scripts/install_prometheus_cpp.sh cartographer/scripts/
RUN cartographer/scripts/install_prometheus_cpp.sh && rm -rf prometheus-cpp
COPY $cartographer_prefix/ cartographer
RUN cartographer/scripts/install_cartographer_cmake_with_grpc.sh && rm -rf cartographer


# ARG CARTOGRAPHER_VERSION=master

# # We require a GitHub access token to be passed.
# ARG github_token

# # Bionic's base image doesn't ship with sudo.
# RUN apt-get update && apt-get install -y sudo

# # First, we invalidate the entire cache if cartographer-project/cartographer has
# # changed. This file's content changes whenever master changes. See:
# # http://stackoverflow.com/questions/36996046/how-to-prevent-dockerfile-caching-git-clone
# ADD https://api.github.com/repos/cartographer-project/cartographer/git/refs/heads/master?access_token=$github_token \
#     cartographer_ros/cartographer_version.json

# # wstool needs the updated rosinstall file to clone the correct repos.
# COPY cartographer_ros.rosinstall cartographer_ros/
# COPY scripts/prepare_catkin_workspace.sh cartographer_ros/scripts/
# RUN CARTOGRAPHER_VERSION=$CARTOGRAPHER_VERSION \
#     cartographer_ros/scripts/prepare_catkin_workspace.sh

# # rosdep needs the updated package.xml files to install the correct debs.
# COPY cartographer_ros/package.xml catkin_ws/src/cartographer_ros/cartographer_ros/
# COPY cartographer_ros_msgs/package.xml catkin_ws/src/cartographer_ros/cartographer_ros_msgs/
# COPY cartographer_rviz/package.xml catkin_ws/src/cartographer_ros/cartographer_rviz/
# COPY scripts/install_debs.sh cartographer_ros/scripts/
# RUN cartographer_ros/scripts/install_debs.sh

# # Install Abseil.
# RUN /catkin_ws/src/cartographer/scripts/install_abseil.sh

# # Build, install, and test all packages individually to allow caching. The
# # ordering of these steps must match the topological package ordering as
# # determined by Catkin.
# COPY scripts/install.sh cartographer_ros/scripts/
# COPY scripts/catkin_test_results.sh cartographer_ros/scripts/

# RUN cartographer_ros/scripts/install.sh --pkg cartographer && \
#     cartographer_ros/scripts/install.sh --pkg cartographer --make-args test

# COPY cartographer_ros_msgs catkin_ws/src/cartographer_ros/cartographer_ros_msgs/
# RUN cartographer_ros/scripts/install.sh --pkg cartographer_ros_msgs && \
#     cartographer_ros/scripts/install.sh --pkg cartographer_ros_msgs \
#         --catkin-make-args run_tests && \
#     cartographer_ros/scripts/catkin_test_results.sh build_isolated/cartographer_ros_msgs

# COPY cartographer_ros catkin_ws/src/cartographer_ros/cartographer_ros/
# RUN cartographer_ros/scripts/install.sh --pkg cartographer_ros && \
#     cartographer_ros/scripts/install.sh --pkg cartographer_ros \
#         --catkin-make-args run_tests && \
#     cartographer_ros/scripts/catkin_test_results.sh build_isolated/cartographer_ros

# COPY cartographer_rviz catkin_ws/src/cartographer_ros/cartographer_rviz/
# RUN cartographer_ros/scripts/install.sh --pkg cartographer_rviz && \
#     cartographer_ros/scripts/install.sh --pkg cartographer_rviz \
#         --catkin-make-args run_tests && \
#     cartographer_ros/scripts/catkin_test_results.sh build_isolated/cartographer_rviz

# COPY scripts/ros_entrypoint.sh /

# RUN rm -rf /var/lib/apt/lists/*
# # A BTRFS bug may prevent us from cleaning up these directories.
# # https://btrfs.wiki.kernel.org/index.php/Problem_FAQ#I_cannot_delete_an_empty_directory
# RUN rm -rf cartographer_ros catkin_ws || true
