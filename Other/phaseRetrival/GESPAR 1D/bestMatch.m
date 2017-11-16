function xBest=bestMatch(x1,x2)
% bestMatch finds the permutation of x1 that matches x2 the best in
% terms of the following ambiguities: circular shift, sign, flipping
[n,m]=size(x1);
minErr=inf;
for kk=1:n
    for signInd=1:2
        for flip=0:1
            if (flip)
                x1shift=flipud(circshift(x1,kk)*(-1)^signInd);
            else
                x1shift=circshift(x1,kk)*(-1)^signInd;
            end
            err=norm(x2-x1shift);
            if err<minErr
                xBest=x1shift;
                minErr=err;
            end
        end
    end
end
end
