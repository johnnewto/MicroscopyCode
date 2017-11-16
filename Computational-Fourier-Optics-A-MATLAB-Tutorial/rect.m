function[out]=rect(x);
%
% rectangle function
%
% evaluates rect(x)
% note: returns odd number of samples for full width
%
out=double(abs(x)<=1/2);
end