function x=DGN(w,S,c,n,x0,iterations,F)
%%% Damped Gauss Newton
x=zeros(2*n,1);
x(S)=x0;
s=0.5;
for i=1:iterations
    s=min([2*s,1]);
    y=fft(x);
    b=sqrt(w).*(abs(y).^2+c);
    B=bsxfun(@times,real(y).*sqrt(w),real(F(:,S)))+bsxfun(@times,imag(y).*sqrt(w),imag(F(:,S)));
    xold=x;
    fold=objectiveFun(w,c,xold);
    x=zeros(2*n,1);
    x(S)=2*B\b;
    if rank(B)<length(S)
        pause;
    end
    xnew=x;
    while((objectiveFun(w,c,xold+s*(xnew-xold))>fold))% && (s>1e-5))
        s=0.5*s;
    end
    x=xold+s*(xnew-xold);
    if (norm(x-xold)<1e-4)
        return
    end
end



