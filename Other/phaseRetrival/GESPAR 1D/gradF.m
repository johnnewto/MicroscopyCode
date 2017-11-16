function out=gradF(w,c,x)
% Returns the gradient of f 
z=fft(x);
out=(length(x)*4*ifft(w.*z.*(abs(z).^2-c)));

