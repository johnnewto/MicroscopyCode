%**************************************************************************
% Fourier Ptychographic Imaging for transparent objects, transmitted light
% Function: Circular mask for the Fourier Transform
% Expects: Mask size, circle center coordinates, circle radius
% Returns: Mask where values in circle are 1, outside are zero
%
% Author: Alankar Kotwal <alankarkotwal13@gmail.com>
%**************************************************************************

function outputImage = circularMask(size, xC, yC, rad)

outputImage = zeros(size);

% Shift origin to (0,0) in image
xCen = xC + size(1)/2;
yCen = yC + size(2)/2;

% Find closest point to (xC, yC)
xCenRound = round(xCen);
yCenRound = round(yCen);

% If distance to center < radius, then pixel = 1
for i=1:size(1)
    for j=1:size(2)
        
        if((xCenRound-i)^2 + (yCenRound-j)^2 < rad^2) % Distance condition
            outputImage(i, j) = 1;
        end
        
    end
end