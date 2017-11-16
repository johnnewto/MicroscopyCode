% Computer generated hologram using the Gerchberg-Saxton algorithm
% Use has been made of (part of) the 'LightPipes for Matlab' optical toolbox
% (http://www.okotech.com)
% Dr F.A. van Goor, University of Twente. April 2010

clear all; %free memory
clc; %clear command window
close all; %close all figures

m=1;
nm=1e-9*m;
mm=1e-3*m;
cm=1e-2*m;

lambda=632.8*nm; %red HeNe laser
size=19.05*mm; %the HoloEye LCD is W x H = 25.4mm x 19.05 mm
N=600; %The HoloEye LCD has W x H = 800 x 600 pixels, we use a square grid

Nitt=5; % number of itererations

original='die.jpg';% die.jpg, test1.bmp, test2.bmp, test3.bmp, point.bmp, bigpoint.bmp, ...
[image,map]=imread(original); % read the original picture from disk

imageD=double(image); %The LightPipes command 'LPSubIntensity' requires an array of doubles as input
clear image; %We don't use image anymore, so clear it 
UniformIntensity=ones(N); % We need a matrix filled with 1's to substitute a uniform intensity profile

figure('Name',sprintf('Original picture: %s',original),'NumberTitle','off');
imshow(imageD,[],'InitialMagnification','fit','Border','tight');

% The Gerchberg-Saxton iteration loop to get the phase distribution
F=LPBegin(size,lambda,N); % We start with a plane wave distribution with amplitude 1 and phase 0
for i=1:Nitt
    F=LPPipFFT(1,F); %Take the 2-D Fourier transform of the field
    F=LPSubIntensity(imageD,F); % Substitute the original intensity distribution, leave the phase unchanged
    F=LPPipFFT(-1,F); % Take the inverse Fourier transform
    F=LPSubIntensity(UniformIntensity,F); % Substitute a uniform intensity, leave the phase unchanged
    fprintf('%d ',i); % monitor the number of iterations done in the command window
end;
Phase=LPPhase(F); %Extract the phase distribution from the field

% Plot the phase distribution on the HoloEye LCD spatial light modulator (SLM)
v=get(0,'MonitorPositions'); % This Matlab command gives the position(s) of the monitor(s) connected to your PC.
if (rank(v) == 2) % rank(v) = 1 means that only one monitor is connected, rank(v) = 2 means that two monitors are connected.
    disp('Dual monitor detected\n');
    figure(1);
    set(gcf,'Position',[v(2,1) v(2,2) 800 600]);  % Set the position of the current figure
    imshow(Phase,[],'InitialMagnification','fit','Border','tight'); % Plot the phase distribution on the second monitor, which should be the 800 x 600 pixels HoloEye LCD
else
    fprintf('\n%s\n','Only one screen detected, connect the HoloEye SLM and set-up dual monitor');
end;

% Repeat the phase plot on your primary screen
figure('Name',sprintf('Calculated phase distribution (hologram)of: %s',original),'NumberTitle','off');
imshow(Phase,[],'InitialMagnification','fit','Border','tight');

% Simulate with LightPipes for Matlab:
F=LPPipFFT(1,F); % Fourier transformation

%Alternative: Use a positive lens to do the Fourier transform as in the experiment (un-comment
%the two commands below, comment the  command above)
%The focal length of the lens must be large enough to prevent aliasing effects due to the
%limitation of the spatial frequencies that the system can handle (Nyquist criterium)
%{
F=LPLens(700*mm,0,0,F); % Insert a lens
F=LPForvard(700*mm,F); %Propagate to the focal plane (This performs a Fourier transform)
%}
figure('Name',sprintf('Simulation of: %s',original),'NumberTitle','off');
I=LPIntensity(1,F); % Extract the intensity from the field (normalized to 1)
imshow(I,[],'InitialMagnification','fit','Border','tight');
