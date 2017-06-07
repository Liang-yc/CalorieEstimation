# Deep Learning-Based Food Calorie Estimation Method in Dietary Assessment[arXiv]()
## Background
------
Obesity is a medical condition in which excess body fat has accumulated to the extent that it may have a negative effect on health.  Obesity treatment requires the patients to eat healthy food and decrease the amount of daily calorie intake. For those patients, it is helpful that calories can be estimated from photos.<br><br>Many methods based on computer vision have been created to estimate calories. <br><br>
This project is used to estimate calories.To estimate calories, it requires the userto take a top view and a side view of the food before eatingwith his/her smart phone. Each images used to estimate mustinclude One Yuan coin. For the top view, we use the deeplearning algorithms to recognize the types of food and applyimage segmentation to identify the food’s contour in thephotos. So as the side view. then, the volumes of each foodis calculated based on the calibration objects in the images.In the end, the calorie of each food is obtained by searchingdensity table and nutrition table. In order to get better results, we choose to use Faster Region-based Convolutional NeuralNetworks (Faster R-CNN) to detect objects and GrabCut as segmentation algorithms.

## Requirement:software
-----

1.Requirements for Fater R-CNN in Matlab;<br>
2.Opencv;<br>
3.CUDA.<br>

## Requirement:hardware
-----

1.Requirements for Fater R-CNN in Matlab;<br>
2.GPU with more than 2GB memeory(If you only want to test, a GPU with only 2GB memory is acceptable).<br>

## File contents
-----
Due to this project's code is mainly baesd on the Faster R-CNN, we only introduct those code we wrote.<br>
1.`density.xls` : foods' density table;<br>
2.`faster_rcnn_rec.m`: this file is used to estimate calorie;<br>
3.`grabcut_mex.cpp` : this file is written by C and is used to calculate volume. Grabcut function in opencv is used;<br>
4.`opencv_mex.m` : compiling grabcut_mex.cpp; if your environment is different from us, modifying this file and recompiling it.<br>
5.`ECUSTFD_ORIGIN_IMAGE_TEST.m `: used for volume estimation in ECUSTFD with original image size;<br>
6.`ECUSTFD_TEST.m `:  used for volume estimation in resized ECUSTFD;<br>
## Experiment Environment
-----
This project is tested on W7x64 with GTX1070. <br>
## Resources
-----
We use ECUSTFD to train and test Faster R-CNN. ECUSTFD is a free public food image dataset. ECUSTFD is available at [github](https://github.com/Liang-yc/ECUSTFD-resized-) or [BaiduYun](http://pan.baidu.com/s/1o8qDnXC). <br>  
If you just want to test Faster R-CNN. You can download the weighted network at this [website](http://pan.baidu.com/s/1pLEYCvL).
  
