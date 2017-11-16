function p = pzernfun(n,m,r,theta)
%PZERNIKE Pseudo-Zernike functions of order N and frequency M on the unit circle.
%   P = PZERNIKE(N,M,R,THETA) returns the pseudo-Zernike functions of 
%   order N and angular frequency M, evaluated at positions (R,THETA) on 
%   the unit circle.  N is a vector of positive integers (including 0), 
%   and M is a vector with the same number of elements as N.  Each element
%   k of M must be a positive integer, with possible values M(k) = -N(k)
%   to +N(k).  R is a vector of numbers between 0 and 1, and THETA is a 
%   vector of angles.  R and THETA must have the same length.  The output 
%   P is a matrix with one column for every (N,M) pair, and one row for 
%   every (R,THETA) pair.
%
%   Example 1: Display the first 25 pseudo-Zernike functions
%
%        % Build a grid
%        x = -1:0.01:1;
%        [X,Y] = meshgrid(x,x);
%        [theta,r] = cart2pol(X,Y);
%        
%        is_in_circle = r<=1;
%        r = r(is_in_circle);
%        theta = theta(is_in_circle);
%        
%        % Compute and display the first 25 pseudo-Zernike functions
%        n_max = 4;
%        N = 2*n_max+1;
%        h = figure('Position',[0 0 800 600],'Visible','off');
%        for n = 0:n_max
%            for m = -n:n
%                P = nan(size(X));
%                P(is_in_circle) = pzernfun(n,m,r,theta);
%                
%                subplot(n_max+1,N,n*N + n_max + m + 1)
%                pcolor(x,x,P), shading interp
%                axis square
%                set(gca,'XTick',[],'YTick',[])
%                title(['P_' num2str(n) '^{' num2str(m) '}(r,\theta)'])
%            end
%        end
%        movegui(h,'center')
%        set(h,'Visible','on')
%
%   Example 2: Pseudo-Zernike moments
%
%        % Build a grid
%        N = 100;
%        x = (-N:2:N)/N;
%        [X,Y] = meshgrid(x);
%        [theta,r] = cart2pol(X,Y);
%        
%        is_in_circle = r <= 1;
%        r = r(is_in_circle);
%        theta = theta(is_in_circle);
%        
%        % Create some data
%        F = peaks(N+1);F = F/max(abs(F(:))); % Normalize
%        F(~is_in_circle) = nan;
%        
%        % Compute a (finite) basis of pseudo-Zernike functions
%        n_max = 7;
%        n = zeros(1,(n_max+1)^2);
%        m = zeros(1,(n_max+1)^2);
%        for k = 0:n_max
%            n(k^2+1:(k+1)^2) = repmat(k,1,2*k+1);
%            m(k^2+1:(k+1)^2) = -k:k;
%        end
%        P = pzernfun(n,m,r,theta);
%        
%        % Estimate the pseudo-Zernike moments, using simple
%        % summation to approxmiate the integrals
%        M = zeros(1,(n_max+1)^2);
%        for k = 1:(n_max+1)^2
%            M(k) = sum(F(is_in_circle)'*P(:,k))*(2/N)^2;
%        end
%        
%        % Use the computed moments to recover the original data
%        F_recovered = nan(size(X));
%        F_recovered(is_in_circle) = P*M';
%        
%        % Display the data
%        h = figure('Position',[0 0 800 300],'Visible','off');
%        axes('Position',[0.05 0.11 0.25 0.8])
%        pcolor(x,x,F), shading interp
%        set(gca,'XTick',[],'YTick',[])
%        axis square
%        title('Original')
%        
%        axes('Position',[0.35 0.11 0.25 0.8])
%        pcolor(x,x,F_recovered), shading interp
%        set(gca,'XTick',[],'YTick',[])
%        axis square
%        title(sprintf('Recovered\n(pseudo-Zernike Moments)'))
%        
%        ha = axes;
%        pcolor(x,x,F-F_recovered), shading interp
%        set(gca,'XTick',[],'YTick',[])
%        axis square
%        title('Difference')
%        colorbar
%        set(ha,'Position',[0.65 0.11 0.25 0.8],'CLim',[min(F(:)) max(F(:))])
%        
%        movegui(h,'center')
%        set(h,'Visible','on')
%
%   See also ZERNPOL, ZERNFUN, ZERNFUN2.

%   Paul Fricker 11/07/2011
%   Copyright 2011 MathWorks, Inc.


% Check and prepare the inputs:
% -----------------------------
if ( ~any(size(n)==1) ) || ( ~any(size(m)==1) )
    error('pzernfun:NMvectors','N and M must be vectors.')
end

if length(n)~=length(m)
    error('pzernfun:NMlength','N and M must be the same length.')
end

n = n(:);
m = m(:);

if any(m>n)
    error('pzernfun:MlessthanN', ...
          'Each M must be less than or equal to its corresponding N.')
end

if any( r>1 | r<0 )
    error('pzernfun:Rlessthan1','All R must be between 0 and 1.')
end

if ( ~any(size(r)==1) ) || ( ~any(size(theta)==1) )
    error('pzernfun:RTHvector','R and THETA must be vectors.')
end

r = r(:);
theta = theta(:);
length_r = length(r);
if length_r~=length(theta)
    error('pzernfun:RTHlength', ...
          'The number of R- and THETA-values must be equal.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the Zernike Polynomials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine the required powers of r:
% -----------------------------------
m_abs = abs(m);
rpowers = [];
for j = 1:length(n)
    rpowers = [rpowers m_abs(j):n(j)]; %#ok<AGROW>
end
rpowers = unique(rpowers);

% Pre-compute the values of r raised to the required powers,
% and compile them in a matrix:
% -----------------------------
if rpowers(1)==0
    rpowern = arrayfun(@(p)r.^p,rpowers(2:end),'UniformOutput',false);
    rpowern = cat(2,rpowern{:});
    rpowern = [ones(length_r,1) rpowern];
else
    rpowern = arrayfun(@(p)r.^p,rpowers,'UniformOutput',false);
    rpowern = cat(2,rpowern{:});
end

% Compute the values of the polynomials:
% --------------------------------------
p = zeros(length_r,length(n));
for j = 1:length(n)
    s = 0:(n(j)-m_abs(j));
    pows = n(j)-s;
    for k = length(s):-1:1
        c = (1-2*mod(s(k),2))*                 ...
               prod(2:2*n(j)+1-s(k))/          ...
               prod(2:s(k))/                   ...
               prod(2:(n(j)+m_abs(j)+1-s(k)))/ ...
               prod(2:(n(j)-m_abs(j)  -s(k)));
        idx = (pows(k)==rpowers);
        p(:,j) = p(:,j) + c*rpowern(:,idx);
    end
    p(:,j) = p(:,j)*sqrt((n(j)+1)*(1+(m_abs(j)~=0))/pi);
end
% END: Compute the Zernike Polynomials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the Zernike functions:
% ------------------------------
idx_pos = m>0;
idx_neg = m<0;

if any(idx_pos)
    p(:,idx_pos) = p(:,idx_pos).*cos(theta*m_abs(idx_pos)');
end
if any(idx_neg)
    p(:,idx_neg) = p(:,idx_neg).*sin(theta*m_abs(idx_neg)');
end

% EOF pzernfun