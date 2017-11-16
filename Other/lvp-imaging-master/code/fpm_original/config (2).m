%**************************************************************************
% Fourier Ptychographic Imaging for transparent objects, transmitted light
% Config file
%
% Author: Alankar Kotwal <alankarkotwal13@gmail.com>
%
% Make sure you run this file from the lvp-imaging directory
%**************************************************************************

% Housekeeping

saveImages = 1;                 % Select if you want to save the raw images
                                % for later analysis. Saved as *.mat
imageFolder = 'images/test';    % Folder for saving the input images

%**************************************************************************

% Imaging system specs

nX = 32;                        % Number of LEDs along X
nY = 32;                        % Number of LEDs along Y
xSep = 0.5;                     % Separation of the LEDs along X, in cm
ySep = 0.5;                     % Separation of the LEDs along Y, in cm
h = 8;                          % Height of the sample from the LED array,
                                % again in cm

%**************************************************************************

% Serial stuff

autodetectSerialPort = 0;       % Choose if you want to autodetect serial
                                % port. Still to be implemented
serialPort = '/dev/ttyS101';    % If above is 0, port name

% Important: Matlab recongizes serial ports of the form ttyS[0-255]
% Make sure the Arduino's port (/dev/ttyACM*) has a symbolic link in /dev 
% which is named /dev/ttyS* (as in the above serialPort variable)
% I have already done this for /dev/ttyACM0 (=> /dev/ttyS101) in setup

%**************************************************************************

% Webcam stuff

webcamName = 'linuxvideo';      % Webcam name used by Matlab, find this
                                % using imaqtool in Matlab
webcamNo = 1;                   % Usually 1. Check in imaqtool
xRes = 1280;                    % X-resolution
yRes = 720;                     % Y-resolution
webcamMode = 'YUYV_1280x720';   % Capturing mode for the webcam. Again,
                                % imaqtool. This should match with the 
                                % above resolution settings.
imagesPerTrigger = 1;           % Number of shots to take per angle

%**************************************************************************

% Output stuff
scale = 10;                     % Factor by which you want to scale the
                                % image pixels