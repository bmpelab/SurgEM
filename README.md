# SurgEM: A Vision-based Surgery Environment Modeling Framework for Constructing a Digital Twin

This repository contains the implementations for our RA-L (open access) paper **[SurgEM: A Vision-based Surgery Environment Modeling Framework for Constructing a Digital Twin towards Autonomous Soft Tissue Manipulation](https://ieeexplore-ieee-org.utokyo.idm.oclc.org/abstract/document/10685073)** (**Best Poster Award** in [ICRA 2024 2nd RAMI workshop](https://sites.google.com/view/rami-icra-2024-workshop/home?pli=1)) and IPCAI 2023 paper **[Occlusion-robust scene flow-based tissue deformation recovery incorporating a mesh optimization model](https://doi.org/10.1007/s11548-023-02889-z)** (**CAI Award Runner-up** in [IPCAI 2023](https://sites.google.com/view/ipcai-2023/home)) by [Jiahe Chen](http://), Etsuko Kobayashi, Ichiro Sakuma, and Naoki Tomii.

## Overview

Surgery environment modeling (SurgEM) framework is for fast and easy combination of modules for general research in computer assisted intervention (CAI). Now the major usage of SurgEM is to model the tool-tissue interaction during soft tissue manipulation, involving the deformation of the soft tissue (geometry, texture, engineering surface strain), the pose of the instrument (geometry, position, orientation), and tool-tissue distance.



https://github.com/user-attachments/assets/5ea78d38-11a3-4a56-b3b2-250e82ea0da2



We implement the ROS system to enable the communication among modules. The information flow of the SurgEM system is as follows:

![Picture1](https://github.com/user-attachments/assets/e41ac5fb-fe5c-4097-a92f-a9ada472bf5d)

However, since the whole system is heavy and the system setting process could be very different depending on the exact hardware in use, we currently do not release everything, especially those tedious and platform-dependent instructions (with read bounding box). Instead, we start from the green bounding box, assuming that the information from the previous steps are available. For those steps in the grey bounding box, please refer to the links below:
1. Stereo rectification: [OpenCV_stereoRectify](https://docs.opencv.org/4.x/d9/d0c/group__calib3d.html#ga617b1685d4059c6040827800e72ad2b6)
2. 3D reconstruction: [RAFT-Stereo](https://github.com/princeton-vl/RAFT-Stereo.git)
3. 2D tracking: [LiteFlowNet3](https://github.com/twhui/LiteFlowNet3.git)

## Dataset preparation

We provide a tiny but useful ex vivo dataset for the reconstruction accuracy evaluation in both the non-occluded and occluded areas. For the details about how we acquire the dataset, please check our RA-L paper. You can download our well-prepared dataset from [here](https://drive.google.com/drive/folders/1TZbrjPlJ6zwMm2HGsjIHRQuQyMRHEEcb?usp=sharing). This dataset includes:

```shell
├── surgem_ex_vivo
    ├── g1
        ├── constraint_map
        ├── point_3d_map
        ├── mask
        ├── scene_flow
        ├── rectified_left
        ├── rectified_right
        ├── evaluation
        ├── 0.stl (the initial mesh)
        ├── rectifiedCamera.mat (camera parameter)
    ├── g2
        ├── constraint_map
        ├── point_3d_map
        ├── mask
        ├── scene_flow
        ├── rectified_left
        ├── rectified_right
        ├── evaluation
        ├── 0.stl (the initial mesh)
        ├── rectifiedCamera.mat (camera parameter)
```


If you would like to prepare your own dataset, please refer to the above structure.

## Running options

If you use our dataset or have created your own constraint maps, leave `pose_flag` as `true`. In this case, you are using the implementation of our RA-L paper, where the instrument pose information is used for optimization. If you do not use or the pose information is unavailable in your application, please change the `pose_flag` to `false`. In this case, the implementation is the one in our IPCAI paper.
Note that in both case the instrument masks are necessary in the case of occlusion. If the instrument does not cause occlusion or you do not want to use instrument masks, set `mask_flag` to `false`.

## Run

For easy testing, we implement our demo using MATLAB, which can be run with no effort in environment setting. First clone or download this repository. Then, open `main.m` in MATLAB, adjust the `data_folder` to the one of the dataset. 

After that, run the code. New folders (`mesh`) containing the results will be created under the same folder of the dataset.

## Evaluation

We provide a tiny but useful ex vivo dataset for the reconstruction accuracy evaluation in both the non-occluded and occluded areas. For details about the evaluation, please check the dataset.

## Citation

If you use our ex vivo dataset or find this work helpful, please cite our paper:

```
@article{chen2024surgem,
  title={SurgEM: A Vision-based Surgery Environment Modeling Framework for Constructing a Digital Twin towards Autonomous Soft Tissue Manipulation},
  author={Chen, Jiahe and Kobayashi, Etsuko and Sakuma, Ichiro and Tomii, Naoki},
  journal={IEEE Robotics and Automation Letters},
  year={2024},
  publisher={IEEE}
}
```

If you choose to use our implementation with `pose_flag == false`, please cite this paper:

```
@article{chen2023occlusion,
  title={Occlusion-robust scene flow-based tissue deformation recovery incorporating a mesh optimization model},
  author={Chen, Jiahe and Hara, Kazuaki and Kobayashi, Etsuko and Sakuma, Ichiro and Tomii, Naoki},
  journal={International Journal of Computer Assisted Radiology and Surgery},
  volume={18},
  number={6},
  pages={1043--1051},
  year={2023},
  publisher={Springer International Publishing Cham}
}
```

## Acknowledgement

Thanks for the efforts of all authors of the following projects/codes.

1. [natsort](https://www.mathworks.com/matlabcentral/fileexchange/10959-sort_nat-natural-order-sort)
2. [RAFT-Stereo](https://github.com/princeton-vl/RAFT-Stereo.git)
3. [LiteFlowNet3](https://github.com/twhui/LiteFlowNet3.git)
