%   Example 1: Display the first 25 pseudo-Zernike functions

       % Build a grid
       x = -1:0.01:1;
       [X,Y] = meshgrid(x,x);
       [theta,r] = cart2pol(X,Y);
       
       is_in_circle = r<=1;
       r = r(is_in_circle);
       theta = theta(is_in_circle);
       
       % Compute and display the first 25 pseudo-Zernike functions
       n_max = 4;
       N = 2*n_max+1;
       h = figure('Position',[0 0 800 600],'Visible','off');
       for n = 0:n_max
           for m = -n:n
               P = nan(size(X));
               P(is_in_circle) = pzernfun(n,m,r,theta);
               
               subplot(n_max+1,N,n*N + n_max + m + 1)
               pcolor(x,x,P), shading interp
               axis square
               set(gca,'XTick',[],'YTick',[])
               title(['P_' num2str(n) '^{' num2str(m) '}(r,\theta)'])
           end
       end
       movegui(h,'center')
       set(h,'Visible','on')