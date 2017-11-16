% Holographic Optical Element (HOE)
% A HOE lens is made and its phase distribution is transfered to the HoloEye
% LCD spatial light modulator (SLM)
% Dr F.A. van Goor, University of Twente. April 2010

clear all; %free memory
clc; %clear command window
close all; %close all figures

m=1;
nm=1e-9*m;
mm=1e-3*m;
cm=1e-2*m;
deg=pi/180;

lambda=632.8*nm; %red HeNe laser
size=19.05*mm; %the HoloEye LCD is W x H = 25.4mm x 19.05 mm
N=600; %The HoloEye LCD has W x H = 800 x 600 pixels, we use a square grid of 600 x 600 pixels
f=1000*mm; %Focal length of the HOE lens

% Calculate the phase distribution of the HOE lens
%pre-allocate memory, so Matlab does not complain:
Phase=zeros(N,N);
X=zeros(N);
Y=zeros(N);
for i=1:N
    X(i)=-size/2+i*size/N;
    for j=1:N
        Y(j)=-size/2+j*size/N;
        Phase(i,j)=cos((X(i)^2+Y(j)^2)*pi/lambda/f)*1.8;
    end;
end;
clear Y; %We don't use Y anymore, so clear it

% Plot the phase distribution on the HoloEye LCD spatial light modulator (SLM)
v=get(0,'MonitorPositions'); % This Matlab command gives the position(s) of the monitor(s) connected to your PC.
if (rank(v) == 2) % rank(v) = 1 means that only one monitor is connected, rank(v) = 2 means that two monitors are connected.
    disp('Dual monitor detected\n');
    figure(1);
    set(gcf,'Position',[v(2,1) v(2,2) 800 600]);  % Set the position of the current figure
    imshow(Phase,[],'InitialMagnification','fit','Border','tight'); % Plot the phase distribution on the second monitor, which should be the 800 x 600 pixels HoloEye LCD
else
    disp('Only one screen detected, connect the HoloEye SLM and set-up dual monitor');
end;
% Repeat the phase plot on your primary screen
figure ('Name','Phase Distribution HOE lens','NumberTitle','off');
imshow(Phase,[],'InitialMagnification','fit','Border','tight');

%Do a LightPipes for Matlab simulation to simulate the experiment
%You have to increase the focal length to resolve the far field
%pattern. (Remove the comments below)
%{
%A (off-axis)HOE lens can also be made with the interferogram of a spherical and a
%plane wave:
F=LPBegin(size,lambda,N);
Fplane=F; %plane wave
Fplane=LPTilt(0.05*deg,0,Fplane);%tilt the plane wave
Fspherical=LPLens(-f,0,0,F);%spherical wave
F=LPBeamMix(Fspherical,Fplane);%interference
Phase=LPIntensity(1,F)*3.6;%the interference pattern is 'edged' on a glass plate, such that phase jumps of about pi radians occur.
figure ('Name','Simulation1','NumberTitle','off');
imshow(Phase,[],'InitialMagnification','fit','Border','tight');%
%}
%{
F=LPBegin(size,lambda,N);
F=LPSubPhase(Phase,F);
%F=LPLens(f,0,0,F);%To compare with a real lens comment the line above and un-comment this command.
F=LPForvard(f,F);
I=LPIntensity(0,F);
figure ('Name','Simulation2','NumberTitle','off');
imshow(I,[],'InitialMagnification','fit','Border','tight');
figure(5);
plot(X,I(:,N/2));
%axis([-1*mm 1*mm 0 10]);
%}