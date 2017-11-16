function [F,x_real,c]=generate_fft_problem_function_oversampling(n,k)
offset=3;
maxVal=1;
n=2*n;
F=fft(eye(n)); % F is the DFT matrix
n=n/2;
locs=randperm(n);
x=zeros(n,1);
x(locs(1:k))=(rand(k,1)*maxVal+offset).*(-1).^(floor(rand(k,1)*2)+1);
c=abs(fft(x,2*n)).^2;
x_real=x;
end
