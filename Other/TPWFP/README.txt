--------------------------------------------------------------------------------------------------------------------------

  Code demo for "Fourier ptychographic reconstruction using Poisson maximum likelihood and truncated Wirtinger gradient"
                                 Public release v1.0 (Feb. 9th, 2016) 

------------------------------------------------------------------------------------------------------------------------------------
 Contents
------------------------------------------------------------------------------------------------------------------------------------
Note: Before running the codes, please change Matlab current folder to ¡°..\Code_TPWFP_src".

All the subprograms are packed in the "code_source" subfolder.

*) Demo.m                        : This demo does the simulation of the Fourier ptychographic microscopy (FPM) technique, and use TPWFP to reconstruct the HR plural image;
*) fun_FPM_Capture.m             : This function simulates captured low resolution images of FPM;
*) fun_TPWFP_Real.m              : This function runs the TPWFP algorithm;
*) fun_compute_grad_TPWFP_Real   : This function calculates the gradient of the TPWFP algorithm;
*) fun_A_Real.m                  : This function operates the linear transform (namely "A");
*) fun_At_Real.m                 : This function operates the inverse linear transform (namely "A*");
*) gseq.m                        : This function generates the lighting sequence of the LED array in FPM. (Thanks to Xiaoze Ou for offering code samples.)

The "data_source" contains the "Lena" and "Map" image for simulation.
------------------------------------------------------------------------------------------------------------------------------------
 Disclaimer
------------------------------------------------------------------------------------------------------------------------------------

Any unauthorized use of these routines for industrial or profit-oriented activities is expressively prohibited.

------------------------------------------------------------------------------------------------------------------------------------
 Feedback
------------------------------------------------------------------------------------------------------------------------------------

If this code offers help in your research, please cite our paper:
Liheng Bian, Jinli Suo, Xiaoze ou, Jaebum Chung, Changhuei Yang, Feng Chen and Qionghai Dai, 'Fourier ptychographic reconstruction using Poisson maximum likelihood and truncated Wirtinger gradient,'.

If you have any comment, suggestion, or question, please contact Liheng Bian at lihengbian@gmail.com.