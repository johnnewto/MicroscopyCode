--------------------------------------------------------------------------------------------------------------------------

  Code demo software for "Fourier ptychographic reconstruction using Wirtinger flow optimization"
                                 Public release v1.0 (Nov. 23th, 2014) 

------------------------------------------------------------------------------------------------------------------------------------
 Contents
------------------------------------------------------------------------------------------------------------------------------------
Note: Before running the codes, please change Matlab current folder to "..\WFP_src".

All the subprograms are packed in the "code_source" subfolder.

*) Demo.m                   : This demo does the simulation of the Fourier ptychology technique, and use WFP to reconstruct the HR plural image;
*) WFP.m                    : This function runs the WFP algorithm;
*) A_LinearOperator.m       : This function operates the linear transform (namely "A");
*) A_Inverse_LinearOperator.m       : This function operates the inverse linear transform (namely "A*");
*) A_Inverse_LinearOperator.m       : This function creates an simulated pupil function;

The "data_source" contains the "Lena" and "Map" image for simulation.
------------------------------------------------------------------------------------------------------------------------------------
 Disclaimer
------------------------------------------------------------------------------------------------------------------------------------

Any unauthorized use of these routines for industrial or profit-oriented activities is expressively prohibited.

------------------------------------------------------------------------------------------------------------------------------------
 Feedback
------------------------------------------------------------------------------------------------------------------------------------

If this code offers help in your research, please cite our paper:
Liheng Bian, Jinli Suo, Guoan Zheng, Kaikai Guo, Feng Chen and Qionghai Dai, 'Fourier ptychographic reconstruction using Wirtinger flow optimization,' Optics Express, 2015, vol. 23, no. 4, pp. 4856-4866.

If you have any comment, suggestion, or question, please contact Liheng Bian at lihengbian@gmail.com.