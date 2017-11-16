%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main file to implement Fourier Ptychography reconstruction algorithm
% ref
% Lei Tian, et.al, Biomedical Optics Express 5, 2376-2389 (2014).
%
% last modified on 10/07/2015
% by Lei Tian, lei_tian@alum.mit.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% To do list for the user: (marked by 'TODO#')
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) specify where the data located in 'filedir'
% 2) specify where you want to store the results in 'out_dir'
% 3) Find coordinates for estimating background levels and input into 'bk1'
% and 'bk2'.
% 4) specify a threshold value, above which the estimated background value
% is signal rather than noise.
% 5) make sure the LED index (used for taking the images) are properly defined
% in 'lit'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% define weather to reorder by led NA
reorderByLedNA = 0;

%% define # of LEDs used to capture each image
numlit = 1  ;

%% define processing ROI
% JN Np = 200;
Np = 200;
nstart = [1080,1280]-120;

%% diameter of # of LEDs used in the experiment
% 19 gives 293 images or LEDs

dia_led = 6; 
% dia_led = 6;  % = 25 images or LEDs

%%

if (exist('lastnumleds','var') == 0) || lastnumleds ~= numlit
    clear Iall;
    clear Iloaded;
    lastnumleds = numlit;
end

fprintf('Number of LEDs used: %2d \n',numlit);

%% Reconstruction library locates here
addpath(['./FP_Func']);



% raw image size
n1 = 2160; n2 = 2560;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify output folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out_dir = ['output'];
mkdir(out_dir);





%% Load Litidx for 293 images)
load('Litidx293.mat');

%% read system parameters
SystemSetup();

%% Find subset of Iall , prune Iloaded to smaller value
[Lia,WhichImages] = ismember(Litidx,Litidx293); 

%% Load the images
LoadImages();

%% save Litidx 293 , this relates to the 293 stored images
% save('Litidx293.mat',Litidx);

%% Find subset of Iall , prune Iloaded to smaller value


%% load in data: read in the patch from the memory
Imea = double(Iall(nstart(1):nstart(1)+Np-1,nstart(2):nstart(2)+Np-1,:));
% try the reduce start resolution
% Imea = double(Iall(nstart(1):nstart(1)+2*Np-1,nstart(2):nstart(2)+2*Np-1,:));
% Imea = Imea(1:2:end,1:2:end,:);



%% TODO 5: Define the LED index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in this example, the LEDs are scanned sequentially within illumination NA
% defined in the systemsetup();
% In other cases, make the correponding changes. In the end, all we need is
% the matrix 'lit' that specifies the LED index corresponding image.
ledidx = 1:Nled;
if numlit == 1
	ledidx = 1:Nled;
	ledidx = reshape(ledidx,numlit,Nimg);
else
    load('C:\Users\John\Dropbox\FPM stained histology slide\8LED\expt_lit-8.mat');
% 	ledidx = reshape(ledidx,numlit,Nimg);
% 	ledidx = reshape(ledidx,Nimg, numlit);
end
lit = Litidx(ledidx);
lit = reshape(lit,numlit,Nimg);

if(reorderByLedNA == 1)
    % reorder LED indices based on illumination NA
    [dis_lit2,idx_led] = sort(reshape(illumination_na_used,1,Nled));
else % no sort
    dis_lit2 = illumination_na_used;
    idx_led = 1:Nled;
end

Nsh_lit = zeros(numlit,Nimg);
Nsv_lit = zeros(numlit,Nimg);

for m = 1:Nimg
    % corresponding index of spatial freq for the LEDs are lit
    lit0 = lit(:,m);
    Nsh_lit(:,m) = idx_u(lit0);
    Nsv_lit(:,m) = idx_v(lit0);
end

% reorder the LED indices and intensity measurements according the previous
% dis_lit
Ns = [];
Ns(:,:,1) = Nsv_lit;
Ns(:,:,2) = Nsh_lit;

if(reorderByLedNA == 1)
    Imea_reorder = Imea(:,:,idx_led);
    Ibk_reorder = Ibk(idx_led);
else
    Imea_reorder = Imea;
    Ibk_reorder = Ibk;
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-processing the data to DENOISING is IMPORTANT
% background subtraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ithresh_reorder = Imea_reorder;
for m = 1:Nimg
    Itmp = Ithresh_reorder(:,:,m);
    Itmp = Itmp-Ibk_reorder(m);
    Itmp(Itmp<0) = 0;
    Ithresh_reorder(:,:,m) = Itmp;
end

Ns_reorder = Ns(:,idx_led,:);

clear Imea
%% reconstruction algorithm
% select the index of images that will be used in the processing
% Nused = Nled;
Nused = round(Nled);
idx_used = 1:Nused;
I = Ithresh_reorder(:,:,idx_used);
Ns2 = Ns_reorder(:,idx_used,:);
Nimg = Nused;
Nled = Nused;
%% reconstruction algorithm options: opts
%   tol: maximum change of error allowed in two consecutive iterations
    %   maxIter: maximum iterations 
    %   minIter: minimum iterations
    %   monotone (1, default): if monotone, error has to monotonically dropping
    %   when iters>minIter
%   display: display results (0: no (default) 1: yes)
    %   saveIterResult: save results at each step as images (0: no (default) 1: yes)
    %   mode: display in 'real' space or 'fourier' space.
    %   out_dir: saving directory
%   O0, P0: initial guesses for O and P
    %   OP_alpha: regularization parameter for O
    %   OP_beta: regularization parameter for P
%   scale: LED brightness map
%   H0: known portion of the aberration function, 
        % e.g. sample with a known defocus induce a quardratic aberration
        % function can be defined here
%   poscalibrate: flag for LED position correction using
    % '0': no correction
    % 'sa': simulated annealing method
        % calbratetol: parameter in controlling error tolence in sa
    % 'ga': genetic algorithm
    % caution: takes consierably much longer time to compute a single iteration
%   F, Ft: operators of Fourier transform and inverse
opts.tol = 1;
opts.maxIter = 4;
opts.minIter = 2;
opts.monotone = 1;
% 'full', display every subroutin,
% 'iter', display only results from outer loop
% 0, no display
opts.display = 'iter';%'full';%'iter';
upsamp = @(x) padarray(x,[(N_obj-Np)/2,(N_obj-Np)/2]);
% SeedImage = mean(I,3);
if(reorderByLedNA == 1)
    SeedImage = I(:,:,1);
else
    SeedImage = I(:,:,round(Nimg/2));
% 	SeedImage = mean(I,3);
end
opts.O0 = F(sqrt(SeedImage));
opts.O0 = upsamp(opts.O0);
opts.P0 = w_NA;
opts.Ps = w_NA;
opts.iters = 1;
opts.mode = 'fourier';

% jn opts.scale = ones(Nled,1);
opts.scale = ones(Nled,numlit);

opts.OP_alpha = 1;
opts.OP_beta = 1e3;
opts.poscalibrate = 0;
% opts.poscalibrate = 'ga';  % jn

opts.pupilRadius = um_idx;

opts.calbratetol = 1e-1;
opts.F = F;
opts.Ft = Ft;



%% algorithm starts
[O,P,err_pc,c,Ns_cal] = AlterMin(I,[N_obj,N_obj],round(Ns2),opts);

%% save results
fn = ['RandLit-',num2str(numlit),'-',num2str(Nused)];
save([out_dir,'\',fn],'O','P','err_pc','c','Ns_cal');

if(1)
    figure(10); 
    % subplot(121); imagesc(sqrt(I(:,:,1)); axis image; colormap gray; 
    subplot(121); imagesc(sqrt(SeedImage)); axis image; colormap gray; 
    title('Seed image');

    subplot(122); imagesc(abs(O)); axis image; colormap gray; 
    title('Restored image');
    % figure(12); imagesc(real(O)); axis image; colormap gray; axis off
    % figure(13); imagesc(-angle(O),[-.6,1]); axis image; colormap gray; axis off
end

fprintf('processing completes\n');

% Test stuff
if 0 
 %% 
 if numlit == 1
    figure(12);imagesc(sqrt(Imea(:,:,147))); colormap gray;
    figure(13);imagesc(sqrt(I(:,:,147))); colormap gray;
 else
    figure(12);imagesc(sqrt(Imea(:,:,58))); colormap gray;
    figure(13);imagesc(sqrt(I(:,:,58))); colormap gray;
 end;
     
%%    
    Iall_1_3 = Iall(:,:,1:97);
    save('Iall_1','Iall_1_3');
    Iall_2_3 = Iall(:,:,98:200);
    save('Iall_2','Iall_2_3');
    Iall_3_3 = Iall(:,:,201:293);
    save('Iall_3','Iall_3_3');
%%
end

