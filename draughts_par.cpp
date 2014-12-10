#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <string>
#include <CL/cl.h>

#define MAT_SIZE 15

using namespace std;

void err_check( int err, string err_code ) {
	if ( err != CL_SUCCESS ) {
		cout << "Error: " << err_code << "(" << err << ")" << endl;
		exit(-1);
	}
}

int main()
{
	char *drg_board;
	int *drg_nc;
	char *drg_child;
	int *turn;
	int *best_score;
	char *best_move;

	cl_platform_id platform_id = NULL;
	cl_device_id device_id = NULL;
	cl_context context = NULL;
	cl_command_queue command_queue = NULL;
	cl_mem mobj_board = NULL;
	cl_mem mobj_nc = NULL;
	cl_mem mobj_child = NULL;
	cl_mem mobj_turn = NULL;
	cl_mem mobj_best_move = NULL;
	cl_mem mobj_best_score = NULL;
	cl_program program = NULL;
	cl_kernel kernel = NULL;
	cl_uint ret_num_devices;
	cl_uint ret_num_platforms;
	cl_int err;

	drg_board = (char *) malloc(32 * sizeof(char));
	drg_nc = (int *) malloc(sizeof(int));
	drg_child = (char *) malloc(6400 * sizeof(char));
	turn = (int *) malloc(sizeof(int));
	best_score = (int *) malloc(sizeof(int));
	best_move = (char *) malloc(32 * sizeof(char));

	for (int i = 0; i < 32; i++) {
		cin >> drg_board[i];
		best_move[i] = '-';
	}
	cin >> (*turn);
	*drg_nc = 0;

	// Step 01: Get platform/device information 
	err = clGetPlatformIDs( 1, &platform_id, &ret_num_platforms );
	err_check( err, "clGetPlatformIDs" );

	// Step 02: Get information about the device
#ifndef GPU
	err = clGetDeviceIDs( platform_id, CL_DEVICE_TYPE_CPU, 1, &device_id, &ret_num_devices );
#else
	err = clGetDeviceIDs( platform_id, CL_DEVICE_TYPE_GPU, 1, &device_id, &ret_num_devices );
#endif
	err_check( err, "clGetDeviceIDs" );

	// Step 03: Create OpenCL Context
	context = clCreateContext( NULL, 1, &device_id, NULL, NULL, &err );
	err_check( err, "clCreateContext" );

	// Step 04: Create Command Queue
	command_queue = clCreateCommandQueue( context, device_id, 0, &err );
	err_check( err, "clCreateCommandQueue" );

	// Step 05: Create memory objects and tranfer the data to memory buffer
	mobj_board = clCreateBuffer( context, CL_MEM_READ_WRITE, 32 * sizeof(char), NULL, &err );
	err = clEnqueueWriteBuffer( command_queue, mobj_board, CL_TRUE, 0, 32 * sizeof(char), drg_board, 0, NULL, NULL );
	err_check( err, "clEnqueueWriteBuffer" );
	
	mobj_nc = clCreateBuffer( context, CL_MEM_READ_WRITE, sizeof(int), NULL, &err );
	err = clEnqueueWriteBuffer( command_queue, mobj_nc, CL_TRUE, 0, sizeof(int), drg_nc, 0, NULL, NULL );
	err_check( err, "clEnqueueWriteBuffer" );

	mobj_child = clCreateBuffer( context, CL_MEM_READ_WRITE, 6400 * sizeof(char), NULL, &err );
	err = clEnqueueWriteBuffer( command_queue, mobj_child, CL_TRUE, 0, 6400 * sizeof(char), drg_child, 0, NULL, NULL );
	err_check( err, "clEnqueueWriteBuffer" );

	mobj_turn = clCreateBuffer( context, CL_MEM_READ_WRITE, sizeof(int), NULL, &err );
	err = clEnqueueWriteBuffer( command_queue, mobj_turn, CL_TRUE, 0, sizeof(int), turn, 0, NULL, NULL );
	err_check( err, "clEnqueueWriteBuffer" );

	mobj_best_score = clCreateBuffer( context, CL_MEM_READ_WRITE, sizeof(int), NULL, &err );
	err = clEnqueueWriteBuffer( command_queue, mobj_best_score, CL_TRUE, 0, sizeof(int), best_score, 0, NULL, NULL );
	err_check( err, "clEnqueueWriteBuffer" );

	mobj_best_move = clCreateBuffer( context, CL_MEM_READ_WRITE, 32 * sizeof(char), NULL, &err );
	err = clEnqueueWriteBuffer( command_queue, mobj_best_move, CL_TRUE, 0, 32 * sizeof(char), best_move, 0, NULL, NULL );
	err_check( err, "clEnqueueWriteBuffer" );

	// Step 06: Read kernel file
	ifstream file("kernel.cl");
	string prog( istreambuf_iterator<char>( file ), ( istreambuf_iterator<char>() ) );
	const char *source_str = prog.c_str();

	// Step 07: Create Kernel program from the read in source
	program = clCreateProgramWithSource( context, 1, (const char **) &source_str, 0, &err );
	err_check( err, "clCreateProgramWithSource" );

	if (clBuildProgram(program, 1, &device_id, NULL, NULL, NULL) != CL_SUCCESS) {
		char buffer[10240];
		clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, NULL);
		cout << "CL Compilation failed: " << endl << buffer;
		abort();
	}
	// Step 08: Build Kernel Program
//	err = clBuildProgram( program, 1, &device_id, NULL, NULL, NULL );
//	err_check( err, "clBuildProgram" );

	// Step 09: Create OpenCL Kernel
	kernel = clCreateKernel( program, "stack_ab", &err ); err_check( err, "clCreateKernel" );

	// Step 10: Set OpenCL kernel argument
	err = clSetKernelArg( kernel, 0, sizeof( cl_mem ), (void *) &mobj_board );
	err |= clSetKernelArg( kernel, 1, sizeof( cl_mem ), (void *) &mobj_nc );
	err |= clSetKernelArg( kernel, 2, sizeof( cl_mem ), (void *) &mobj_child );
	err |= clSetKernelArg( kernel, 3, sizeof( cl_mem ), (void *) &mobj_turn );
	err |= clSetKernelArg( kernel, 4, sizeof( cl_mem ), (void *) &mobj_best_move );
	err |= clSetKernelArg( kernel, 5, sizeof( cl_mem ), (void *) &mobj_best_score );
	err_check( err, "clSetKernelArg" );

	// Step 11: Execute OpenCL kernel in data parallel
	size_t worksize[] = { 100, 1, 1 };
	clEnqueueNDRangeKernel( command_queue, kernel, 1, NULL, worksize, 0, 0, 0, 0 );
	err_check( err, "clEnqueueNDRangeKernel" );

	// Step 12: Read (Transfer result) from the memory buffer
	err = clEnqueueReadBuffer( command_queue, mobj_best_score, CL_TRUE, 0, sizeof(int), best_score, 0, NULL, NULL );
	err_check( err, "clEnqueueReadBuffer1" );

	// Step 12: Read (Transfer result) from the memory buffer
	err = clEnqueueReadBuffer( command_queue, mobj_nc, CL_TRUE, 0, sizeof(int), drg_nc, 0, NULL, NULL );
	err_check( err, "clEnqueueReadBuffer2" );

	// Step 12: Read (Transfer result) from the memory buffer
	err = clEnqueueReadBuffer( command_queue, mobj_child, CL_TRUE, 0, 6400 * sizeof(char), drg_child, 0, NULL, NULL );
	err_check( err, "clEnqueueReadBuffer3" );

	// Step 12: Read (Transfer result) from the memory buffer
	err = clEnqueueReadBuffer( command_queue, mobj_best_move, CL_TRUE, 0, 32 * sizeof(char), best_move, 0, NULL, NULL );
	err_check( err, "clEnqueueReadBuffer4" );

	// Step 13: Free objects
	err = clFlush( command_queue );
	err = clFinish( command_queue );
	err = clReleaseKernel( kernel );
	err = clReleaseProgram( program );
	err = clReleaseMemObject( mobj_board );
	err = clReleaseMemObject( mobj_nc );
	err = clReleaseMemObject( mobj_child );
	err = clReleaseMemObject( mobj_turn );
	err = clReleaseMemObject( mobj_best_score );
	err = clReleaseMemObject( mobj_best_move );
	err = clReleaseCommandQueue( command_queue );
	err = clReleaseContext( context );

	cout << "pos : ";
	for (int i = 0; i < 32; i++) {
		cout << drg_board[i];
	}
	cout << endl << "nc  : " << *drg_nc << endl;
	cout << "children : " << endl;
	for (int i = 0; i < *drg_nc; i++) {
		int k = i * 32;
		cout << "      ";
		for (int j = k; j < k + 32; j++) {
			cout << drg_child[j];
		}
		cout << endl;
	}
	cout << "best_scr : " << *best_score << endl;
	cout << "best_move : ";
	for (int i = 0; i < 32; i++) {
		cout << best_move[i];
	}
	cout << endl;

	return 0;
}

