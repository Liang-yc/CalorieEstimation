// Interface: convert an image to gray and return to Matlab
// Author : zouxy
// Date   : 2014-03-05
// HomePage : http://blog.csdn.net/zouxy09
// Email  : zouxy09@qq.com

#include "opencv2/opencv.hpp"
#include "mex.h"

using namespace cv;

/*******************************************************
Usage: [imageMatrix] = RGB2Gray('imageFile.jpeg');
Input: 
	a image file
OutPut: 
	a matrix of image which can be read by Matlab

**********************************************************/


void exit_with_help()
{
	mexPrintf(
	"Usage: [imageMatrix] = DenseTrack('imageFile.jpg');\n"
	);
}

static void fake_answer(mxArray *plhs[])
{
	plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
}

void RGB2Gray(char *filename, mxArray *plhs[])
{
	// read the image
	Mat image = imread(filename);
	if(image.empty()) {
		mexPrintf("can't open input file %s\n", filename);
		fake_answer(plhs);
		return;
	}
	
	// convert it to gray format
	Mat gray;
	if (image.channels() == 3)
		cvtColor(image, gray, CV_RGB2GRAY);
	else
		image.copyTo(gray);
	
	// convert the result to Matlab-supported format for returning
	int rows = gray.rows;
	int cols = gray.cols;
	plhs[0] = mxCreateDoubleMatrix(rows, cols, mxREAL);
	double *imgMat;
    imgMat = mxGetPr(plhs[0]);
	for (int i = 0; i < rows; i++)
		for (int j = 0; j < cols; j++)
			*(imgMat + i + j * rows) = (double)gray.at<uchar>(i, j);
	
	return;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if(nrhs == 1)
	{
		char filename[256];
		mxGetString(prhs[0], filename, mxGetN(prhs[0]) + 1);
		if(filename == NULL)
		{
			mexPrintf("Error: filename is NULL\n");
			exit_with_help();
			return;
		}

		RGB2Gray(filename, plhs);
	}
	else
	{
		exit_with_help();
		fake_answer(plhs);
		return;
	}
}