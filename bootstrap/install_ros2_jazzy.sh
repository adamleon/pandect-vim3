#!/bin/bash
set -e

# This script installs ROS 2 Jazzy on Ubuntu 24.04.
# Run with: sudo ./install_ros2_jazzy.sh

# Check for root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

# --- Parse argument ---
ROS_DISTRO="$1"

# Check if ROS_DISTRO is set, if not, exit with an error
if [[ "$ROS_DISTRO" != "humble" && "$ROS_DISTRO" != "jazzy" ]]; then
  echo "❌ Invalid argument: '$ROS_DISTRO'"
  echo "Usage: sudo ./install_ros.sh [humble|jazzy]"
  exit 1
fi

echo "📦 Installing ROS 2 $ROS_DISTRO..."

# Ensure locale is set correctly
apt update && apt install -y locales
locale-gen en_US en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Add ROS 2 apt repository
apt install -y curl gnupg lsb-release software-properties-common
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/ros.gpg
sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/ros.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list'

# Install ROS 2 base
apt update
apt install -y ros-${ROS_DISTRO}-desktop python3-colcon-common-extensions python3-rosdep

# Initialize rosdep
rosdep init || echo "rosdep already initialized"
rosdep update

# Add ROS 2 to shell
sudo echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /etc/skel/.bashrc
echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

echo "✅ ROS 2 ${ROS_DISTRO} installed successfully!"