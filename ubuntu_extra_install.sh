# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb



# 1Passowrd
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt update && sudo apt install 1password


# Python
PYTHON_VERSION="3.10.0"
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION
upgrade python

# Misc
sudp apt-get install fonts-firacode

# Go to Software & Updates and install latest nvidia driver


# Nvidia Docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker


# Check here for latest: https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_local
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.5.0/local_installers/cuda-repo-ubuntu2004-11-5-local_11.5.0-495.29.05-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-5-local_11.5.0-495.29.05-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-5-local/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda

export PATH=/usr/local/cuda-11.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-11.0/lib64:$LD_LIBRARY_PATH


# Docs: https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#installlinux-deb
# CuDnn download from here https://developer.nvidia.com/cudnn
sudo apt install zlib1g
sudo dpkg -i libcudnn8_x.x.x-1+cudax.x_amd64.deb
sudo dpkg -i libcudnn8-dev_8.x.x.x-1+cudax.x_amd64.deb
sudo dpkg -i libcudnn8-samples_8.x.x.x-1+cudax.x_amd64.deb


# Spotify
snap install spotify
snap install slack --classic

# Mouse wheel
sudo apt install imwheel
http://www.nicknorton.net/mousewheel.sh

# Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text

# https://github.com/xxxserxxx/gotop

# VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code # or code-insiders


# POP Stuff
# https://support.system76.com/articles/pop-shell/
# https://github.com/pop-os/shell/issues/1182
# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig
# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/share/pkgconfig


# Typora
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt-get update
sudo apt-get install typora

# Wireguard
sudo apt install wireguard
apt-get install resolvconf
# /etc/wireguard/wg0.conf
# wg-quick up wg0

# MPV
sudo apt install mpv


#Python 

sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt install python3-pip
sudo apt install python3.10 python3.10-venv
python3.10 -m pip install --upgrade pip --user

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.9 2
sudo update-alternatives --config python


python -m venv venv
source venv/bin/activate
python --version


# Don't do: python3.10 -m ensurepip --upgrade --user

# OpenCV/OpenMVG
sudo apt update && sudo apt install -y cmake g++ wget unzip
wget -O opencv.zip https://github.com/opencv/opencv/archive/master.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/master.zip
unzip opencv.zip
unzip opencv_contrib.zip
mkdir -p opencv_build && cd opencv_build

cmake \
      -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-master/modules \
      -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D INSTALL_C_EXAMPLES=OFF \
      -D OPENCV_ENABLE_NONFREE=ON \
      -D BUILD_EXAMPLES=ON \
      -D WITH_CUDA=ON \
      -D WITH_CUDNN=ON \
      -D OPENCV_DNN_CUDA=ON \
      -D WITH_CUBLAS=ON \
      -D ENABLE_FAST_MATH=1 \
      -D CUDA_FAST_MATH=1 \
../opencv-master
sudo cmake --build . --target install -- -j"$(nproc)"

git clone --recursive https://github.com/openMVG/openMVG.git
sudo apt-get install libpng-dev libjpeg-dev libtiff-dev libxxf86vm1 libxxf86vm-dev libxi-dev libxrandr-dev graphviz
mkdir openmvg_build && cd openmvg_build

cmake -DCMAKE_BUILD_TYPE=RELEASE -DOpenMVG_USE_OCVSIFT=ON -DOpenCV_DIR="../opencv_build" -DOpenMVG_USE_OPENCV=ON ../openMVG/src/
sudo cmake --build . --target install -- -j"$(nproc)"