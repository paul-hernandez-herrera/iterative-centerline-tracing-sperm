# 3D+*t* Human Sperm Flagellum Tracing 
# Iterative algorithm for tracing one-branch tubular structures

![Sperm's flagellum tracing overview](/figures/iterative_centerline_tracing_Overview.png)

An iterative tracing algorithm designed to extract the center-line of single tubular structures from a 3D+*t* low contrast and noisy image stack. The center-line is obtained using a machine learning approach and a minimal path algorithm. The algorithm allows to extract several single tubular structures from a 3d image stack.

- Hernandez-Herrera P., Montoya F., Rendon-Mancha J.M., Darszon A., & Corkidi G., [*Sperm Flagellum Center-Line Tracing in Fluorescence 3D+t Low SNR Stacks Using an Iterative Minimal Path Method*](https://doi.org/10.1007/978-3-319-59876-5_48 ). In Proc. 14th  International Conference Image Analysis and Recognition (ICIAR), Montreal, Canada, Jul. 5-7, 2017, pp. 437-445.

- Hernandez-Herrera P., Montoya F., Rendon-Mancha J.M., Darszon A., & Corkidi G.,  [*3D+t Human Sperm Flagellum Tracing in low SNR Fluorescence Images*](https://doi.org/10.1109/TMI.2018.2840047). IEEE Transactions on Medical Imaging, 37(10), 2236-2247, 2018. 

Please cite the paper(s) if you are using this code in your research.

## Overview
The current approach is designed to extract the sperm flagellum's center-line. however it can be applied to similar structures. **The algorithm only requires as input 3D image stack and the expected sizes (radius) of the structures to detect**. The algorithm automatically output the 3D-coordinates for the centerline of each sperm in the 3D image stack. The algorithm has four main steps:
- *Preprocessing (**Step 1**)*: To increase the contrast of the structures, the intensity is mapped to the interval [1,255] and the logarithm is applied. 
- *Flagellum enhancement/probability (**Step 2**)*: The [MESON](https://github.com/paul-hernandez-herrera/meson_matlab) algorithm is applied to enhance brigth structures. It outputs a 3D image stack with values in range [0,1] where values close to zero are assigned to background while close to one to bright-structures. 
- *Head segmentation (**Step 3**)*: The sperm's head is detected using a thresholding approach (the user needs to provide the threshold value) or automatically using a modified version of the Otsu algorithm (default method).
- *Iterative-centerline tracing (**Step 4**)*: 
	a) Start point detection: Each connected component in the stack *Head segmentation* is detected and the center is computed as the initial point of the iterative algorithm.
	b) Minimal cost-path: Given the start/initial point a minimal cost path is propagate until it reaches a predefined-length (number of voxels to extract in the current iteration). Higher values are given to bright-structures, such that the front propagate faster in the flagellum than in the background.
	c) Back-propagation: The algorithm is backpropagate from the point where it stopped in step *4b* (this outputs the center-line).
	d) Stopping criteria: based on the meson probability and the direction of the center-line the algorithm can continue or stop.
	e) Iterate: If the algorithm continues, the next iteration repeats step *4b* to *4e* where the new start point is the point where it stopped in the current iteration.
- *Iterative across time (**Step 5/Optional**)*: in case that the user has a temporal stack (time), it can repeat the algorithm for the next time point where the parameter  ***approximate_head_pos*** is given by the sperm's head center position in the current time point.

## System requirements
- Tested on Matlab R2020a
- Linux and Windows. Not tested on Mac but it may work.
- At least 4GB to process a 640x480x140 image stack.

## Dependencies
- The tracing algorithm depends on the code implementation of the [*MESON algorithm*](https://github.com/paul-hernandez-herrera/meson_matlab) [[1]](#1) [[2]](#2) to compute the probability of bright-structures.

## Instalation

1. Download the lastest release of the code [here]()
2. Make sure to add the downloaded codes to the Matlab Path.
3. Compile the MEX files using the function compile_mex.m 

## Usage single 3d-stack
**Requirements**: 3D image stack in tif format and the radii size in voxel of the structures to detect.

**Open MATLAB 2020 or newer** (it may work with older versions) and type:
```
trace_centerline_iterative(file_path, 'radius', [r1 r2 r3 ... rn])
```
where r1, r2, r3, ..., rn are the expected radii. If the user does not provide the radii parameter, then the default value is used. 

A csv file containing the *x,y,z* coordinates of the center-line for each sperm will be created in the folder containing the 3D input image. 

## Usage 3d+t stack
The algorithm can be applied iteratively to each time point to track and trace the center-line. Each spermatozoa is assigned a unique identifier such that it be identified across times. We provide a 3d+t dataset it is located in **data/data_270516_Exp3.zip**, you need to unzip it. It can be reconstructed by:
- **Open MATLAB 2020 or newer** (it may work with older versions) and type:
- ```test_3d_plus_t_human_sperm_tracing```

The tracing output are the flagellum's center-line coordinates for each sperm. 

## References
<a id="1">[1]</a>  Hernandez-Herrera, P., Papadakis, M., & Kakadiaris, I. A. (2014, April). Segmentation of neurons based on one-class classification. In 2014 IEEE 11th International Symposium on Biomedical Imaging (ISBI) (pp. 1316-1319). IEEE.

<a id="1">[2]</a>  Hernandez-Herrera, P., Papadakis, M., & Kakadiaris, I. A. (2016). Multi-scale segmentation of neurons based on one-class classification. Journal of neuroscience methods, 266, 94-106.