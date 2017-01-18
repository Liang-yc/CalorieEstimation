%// This make.m is for MATLAB
%// Function: compile c++ files which rely on OpenCV for Matlab using mex
%// Author : zouxy
%// Date   : 2014-03-05
%// HomePage : http://blog.csdn.net/zouxy09
%// Email  : zouxy09@qq.com

%% Please modify your path of OpenCV
%% If your have any question, please contact Zou Xiaoyi

% Notice: first use "mex -setup" to choose your c/c++ compiler
clear all;

%-------------------------------------------------------------------
%% get the architecture of this computer
is_64bit = strcmp(computer,'MACI64') || strcmp(computer,'GLNXA64') || strcmp(computer,'PCWIN64');


%-------------------------------------------------------------------
%% the configuration of compiler
% You need to modify this configuration according to your own path of OpenCV
% Notice: if your system is 64bit, your OpenCV must be 64bit!
out_dir='./';
CPPFLAGS = ' -O -DNDEBUG -I.\ -IC:\opencv3.0\opencv\build\include\opencv2 -IC:\opencv3.0\opencv\build\include\opencv -IC:\opencv3.0\opencv\build\include'; % your OpenCV "include" path
LDFLAGS = ' -LC:\opencv3.0\opencv\build\x64\vc12\lib -LC:\opencv3.0\opencv\build\x64\vc12\staticlib';					   % your OpenCV "lib" path
%LIBS = ' -lopencv_calib3d300 -lopencv_contrib300 -lopencv_core300 -lopencv_features2d300 -lopencv_flann300 -lopencv_gpu300 -lopencv_highgui300 -lopencv_imgproc300 -lopencv_legacy300 -lopencv_ml300 -lopencv_nonfree300 -lopencv_objdetect300 -lopencv_photo300 -lopencv_stitching300 -lopencv_ts300 -lopencv_video300 -lopencv_videostab300';
%LIBS='-lopencv_ts300 -lopencv_world300 -lopencv_calib3d300 -lopencv_core300 -lopencv_features2d300 -lopencv_flann300d -lopencv_hal300d -lopencv_highgui300d -lopencv_imgcodecs300d -lopencv_imgproc300d -lopencv_ml300d -lopencv_objdetect300d -lopencv_photo300d -lopencv_shape300d -lopencv_stitching300d -lopencv_superres300d -lopencv_video300d -lopencv_videoio300d -lopencv_videostab300d';
LIBS='-lopencv_ts300 -lopencv_world300';
if is_64bit
	CPPFLAGS = [CPPFLAGS ' -largeArrayDims'];
end
%% add your files here!
compile_files = { 
	% the list of your code files which need to be compiled
	'grabcut_mex.cpp'
};


%-------------------------------------------------------------------
%% compiling...
for k = 1 : length(compile_files)
    str = compile_files{k};
    fprintf('compilation of: %s\n', str);
    str = [str ' -outdir ' out_dir CPPFLAGS LDFLAGS LIBS];
    args = regexp(str, '\s+', 'split');
    mex(args{:});
end

fprintf('Congratulations, compilation successful!!!\n');