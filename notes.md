# Mount
sudo apfs-fuse -o uid=1000,gid=1000,allow_other /dev/sdb2 /mnt/backup

# Put in: /etc/systemd/system/ethtool.service
[Unit]
Description=Mount drives

[Service]
ExecStart=/home/aswerdlow/bin/mount.sh

[Install]
WantedBy=multi-user.target


# Run to enable: systemctl enable ethtool

# python3 func.py update_dynamic_dns


# Extra
 -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-11.5 \
      -D OpenCL_LIBRARY=/usr/local/cuda-11.5/lib64/libOpenCL.so \
      -D OpenCL_INCLUDE_DIR=/usr/local/cuda-11.5/include/ \
      -D OPENCV_PYTHON3_VERSION=ON \
option(OpenMVG_USE_OCVSIFT "Add or not OpenCV SIFT in available features" ON)



rclone copy --progress gdrive:/data .
# sudo docker run -it julianassmann/opencv-cuda:cuda-10.2-opencv-4.2 /bin/bash
import numpy as np
import cv2
from cv2 import cuda
cv2.getBuildInformation()


CONTAINER_ID=datamachines/cudnn_tensorflow_opencv:11.4.2_2.6.0_4.5.4-20211029 ./runDocker.sh -d /home/aswerdlow/streetview

rclone sync -P gdrive:/data data

rclone sync -P ~/streetview/data/kvld_matches.p gdrive:/data


# images = {j:cv2.cvtColor(cv2.imread(f'{images_dir}/{j}.png'), cv2.COLOR_BGR2RGB) for j in [f[:-4] for f in os.listdir(images_dir) if f.endswith('.png')]}
# pickle.dump(images, open(f"{images_dir}/images.p", "wb"))
images = pickle.load(open(f"{images_dir}/images.p", "rb"))


sudo docker run -it -v ~/streetview:/home/ opencv_cuda /bin/bash


TAG=streetview:test11 && sudo docker build -t $TAG .
TAG=streetview:test3 && sudo docker build -t $TAG . && sudo docker run -it -v ~/streetview:/home/ $TAG /bin/bash


TAG=streetview:openmvg_no_cuda && sudo docker build -t $TAG . && sudo docker run -it -v ~/streetview:/home/ $TAG python3 /home/MonocularStreetViewLocalization/test_localization.py

python3 -c 'import cv2; print(dir(cv2.cuda))'




TAG=streetview:openmvg && sudo docker build --build-arg=20 -t $TAG . && sudo docker run -it -v ~/streetview:/home/ -v $CCACHE_DIR:/ccache $TAG /bin/bash

cmake -DCMAKE_BUILD_TYPE=RELEASE -DOpenMVG_USE_OCVSIFT=ON -DOpenCV_DIR="../opencv_build" -DOpenMVG_USE_OPENCV=ON ../openMVG/src/
sudo cmake --build . --target install -- -j"$(nproc)"


export data_dir=/home/aswerdlow/Downloads/data
python3 software/SfM/SfM_SequentialPipeline.py $data_dir/images $data_dir/output
./Linux-x86_64-RELEASE/openMVG_main_exportMatches -i $data_dir/output/matches/sfm_data.json -d $data_dir/output/matches -m $data_dir/output/matches/matches.putative.bin -o $data_dir/output

python3 -c "import mujoco_py;print('gpu' in str(mujoco_py.cymj).split('/')[-1])"

python3 -c "import mujoco_py;print(mujoco_py.cymj)"