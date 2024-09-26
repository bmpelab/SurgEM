# SurgEM: A Vision-based Surgery Environment Modeling Framework for Constructing a Digital Twin

This repository contains the implementations for our RA-L paper **[SurgEM: A Vision-based Surgery Environment Modeling Framework for Constructing a Digital Twin towards Autonomous Soft Tissue Manipulation](https://)** (**Best Poster Award** in related [ICRA 2024 2nd RAMI workshop](https://sites.google.com/view/rami-icra-2024-workshop/home?pli=1)) and IPCAI 2023 paper **[Occlusion-robust scene flow-based tissue deformation recovery incorporating a mesh optimization model](https://doi.org/10.1007/s11548-023-02889-z)** (**CAI Award Runner-up**) by [Jiahe Chen](http://), Etsuko Kobayashi, Ichiro Sakuma, and Naoki Tomii.

## Overview

Surgery environment modeling (SurgEM) framework is for fast and easy combination of modules for general research in computer assisted intervention (CAI). Now the major usage of SurgEM is to model the tool-tissue interaction during soft tissue manipulation, involving the deformation of the soft tissue (geometry, texture, engineering surface strain), the pose of the instrument (geometry, position, orientation), and tool-tissue distance.

We implement the ROS system to enable the communication among modules. The information flow of the SurgEM system is as follows:



However, since the whole system is heavy and the system setting process could be very different depending on the exact hardware in use, we currently do not release those tedious and platform-dependent instructions (which are those in the red bounding box). Instead, we start from the green bounding box, assuming that the information from the previous steps are available. For those steps in the grey bounding box, please refer to the links below:
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
    ├── g2
        ├── constraint_map
        ├── point_3d_map
        ├── mask
        ├── scene_flow
        ├── rectified_left
        ├── rectified_right
        ├── evaluation
```


If you would like to prepare your own dataset, please refer to the above structure.

## Running options

If you use our dataset or have created your own constraint maps, leave `pose_flag` as `true`. In this case, you are using the implementation of our RA-L paper, where the instrument pose information is used for optimization. If you do not use or the pose information is unavailable in your application, please change the `pose_flag` to `false`. In this case, the implementation is the one in our IPCAI paper.
Note that in both case the instrument masks are necessary in the case of occlusion. If the instrument does not cause occlusion or you do not want to use instrument masks, set `mask_flag` to `false`.

## Run

For easy testing, we implement our demo using MATLAB, which can be run with no effort in environment setting. First clone or download this repository. Then, run main.m in MATLAB. New folders (mesh) containing the results will be created under the same folder of the dataset.

## Evaluation

We provide a tiny but useful ex vivo dataset for the reconstruction accuracy evaluation in both the non-occluded and occluded areas. For details about the evaluation, please check the dataset.

## Citation

If you use our ex vivo dataset or find this work helpful, please cite our paper:

```
@article{chen_surgem_2024,
 author = {Chen, Jiahe and Kobayashi, Etsuko and Sakuma, Ichiro and Tomii, Naoki},
 title = {{SurgEM: A Vision-based Surgery Environment Modeling Framework for Constructing a Digital Twin towards Autonomous Soft Tissue Manipulation}},
 journal={Robotics and Automation Letter},
 pages = {xxx--xxx},
 year = {2024},
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

1. readflow code
2. natsort
3. RAFT-Stereo
4. LiteFlowNet3
5. readpy
