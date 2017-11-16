function pupil = Creat_Pupil(r,M,N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, May 1st, 2014.
% This function creates an initial pupil function matrix M*N with a radius
% of r. In the pupil cicle, the matrix values are 1, while outside the
% cicle are 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 2
    N = M;
end
pupil = zeros(M,N);

for i = floor(M/2-r):ceil(M/2+r)
    for j = floor(N/2-r):ceil(N/2+r)
        if((i-M/2)^2+(j-N/2)^2<r^2)
            pupil(i,j)=1;
        end
    end
end

end