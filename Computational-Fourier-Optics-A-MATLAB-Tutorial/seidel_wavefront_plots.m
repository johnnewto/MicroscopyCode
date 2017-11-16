x=-1:0.01:1; y=x;
[X,Y]=meshgrid(x,y);
u0=1; v0=0;
wd=0; w040=1; w131=0; w222=0; w220=0; w311=0;
w=seidel_5(u0,v0,X,Y,wd,w040,w131,w222,w220,w311);
P=circ(sqrt(X.^2+Y.^2));
mask=(P==0);
w(mask)=NaN;

figure(1)
surfc(x,y,w)
camlight left; lighting phong; 
colormap('gray'); shading interp;
xlabel('x'); ylabel('y');
