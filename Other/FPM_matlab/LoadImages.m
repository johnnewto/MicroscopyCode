%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify the file directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numlit == 1
% 	filedir = ['C:\Users\John\Dropbox\Resolution_Target_1LED\data\'];
%     filedir = ['C:\Users\John\Dropbox\FPM stained histology slide\1LED\tif\'];
    filedir = ['C:\Users\John\Dropbox\Resolution_Target_1LED\data\'];
    
else
    filedir = ['C:\Users\John\Dropbox\FPM stained histology slide\8LED\tif\'];
end

% Generate the image list, in 'tif' image format (depending on your image format)
imglist = dir([filedir,'*.tif']);
% imglist = imglist(1:20);


%% read in all images into the memory first
Nimglist = length(imglist);
Nimg = length(WhichImages);
if (exist('Iall','var') == 0) || (size(Iall,3) ~= Nimg )
    fprintf(['loading the images...\n']);
    tic;

    Iall = zeros(n1,n2,Nimg,'uint16');
    Ibk = zeros(Nimg,1);

    count = 0;
    for m = 1:Nimglist
        if(find(WhichImages == m))
            count = count + 1;
            fprintf(['loading ',imglist(m).name, '\n']);
            fn = [filedir,imglist(m).name];
            % all image data
            img = imread(fn);
%             imwrite(img, [fn,'.png']);
            Iall(:,:,count) = img;       
% % %         fn = [imglist(m).name,'.png'];
% % %         imwrite(img, fn);
        end
    end

    fprintf(['\nfinish loading images\n']);
    toc;
end

%% specify background region coordinates
for m = 1:Nimg
    % background noise esimtation 
    bk1 = mean2(double(Iall(34:84,26:76,m)));
    bk2 = mean2(double(Iall(300:350,2050:2100,m)));
    Ibk(m) = 0.5 * mean([bk1,bk2]);
    % brightfield background processing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO 4: if Ibk is larger than some threshold, it is not noise! (chnage 
    % this value correpondingly)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if Ibk(m)>3500
        if m == 1
            Ibk(m) = 190;
        else
            Ibk(m) = Ibk(m-1);
        end
    end
    
    
    Ibk(m) = 200;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%