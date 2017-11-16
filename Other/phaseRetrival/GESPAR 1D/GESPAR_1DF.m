function [x_n,fMin,replacements]=GESPAR_1DF(c,n,k,iterations,verbose,F,ac,noisy,replacementsSoFar,totalReplacements,thresh,randomWeights)
% Performs the 2-opt method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters:
% -------------------------------------
% c = Fourier magnitude measurements.
% n = length of input signal
% iterations = number of DGN inner iterations
% verobse = write stuff (1) or not (0)
% F = DFT matrix
% ac = autocorrelation sequence
% noisy = use ac info for support (0) or not (1)
% replacementsSoFar = How many index replacements were done so far in previous initial points
% totalReplacements = Max. number of allowed replacements
% thresh = stopping criteria for objective function
% randomWeights = use random weights for different measurements (1) or all measurements have equal weights (0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize support
if (noisy)
    noACSupp=1; % Do not use Autocorrelation support info
else
    noACSupp=0; % Use Autocorrelation support info only in the noiseless case
end
ac(abs(ac)<1e-8)=0;
acOffSupp=find(ac==0);
maxAC=max(find(ac));
acOffSuppMax=maxAC+1-find(ac==0);
acOffSuppMax(acOffSuppMax<1)=0;
acOffSuppMax(acOffSuppMax>n)=0;
acOffSuppMax=nonzeros(acOffSuppMax);
acOffSupp=unique([acOffSupp;acOffSuppMax]);
if (noACSupp)
    acOffSupp=[];
end

p=randperm(n-1)+1;
p = setdiff(p,acOffSupp);
p=p(randperm(length(p)));
replacements=0; % counts how many index replacements are done 
if (randomWeights)
    w=1+(rand(2*n,1)<0.5); % Use random weights
else
    w=ones(2*n,1); 
end
p(p==1)=0;
p(p==maxAC)=0;
p=nonzeros(p)';
if (length(p)+2<k)
    k=max(2,length(p)+2);
end
supp=[1 maxAC p(1:k-2)];
if (noACSupp)
    supp=[1 p(1:k-1)];
end
x_k=DGN(w,supp,c,n,randn(k,1),iterations,F); % Damped-Gauss-Newton, Initial guess
replacements=replacements+1;
fMin=objectiveFun(w,c,x_k);
it=0;
while(1)
    it=it+1;
    %% Main iteration
    [junk,idx]=sort(abs(x_k(supp)));
    supp=supp(idx); % Sorting supp from min(abs(x_k)) to max
    fGrad=gradF(w,c,x_k);
    offSupp=setdiff(1:n,supp);
    offSupp=setdiff(offSupp,acOffSupp); 
    [junk,idx]=sort(-abs(fGrad(offSupp)));
    offSupp=offSupp(idx);
    pSupp=1:length(supp);
    pOffSupp=1:length(offSupp);
    improved=0;
        for iInd=1:(min(1,length(supp)))
            i=supp(pSupp(iInd)); %Index to remove
            if (noACSupp)
                if (i==1)
                    continue %Never remove 1st element
                end
            else
                if (i==1 || i==maxAC)
                    continue %Never remove 1st and last element
                end
            end
            for jInd=1:(min(1,length(offSupp)))
                j=offSupp(pOffSupp(jInd)); % Index to insert
                %% Check replacement
                suppTemp=supp;
                suppTemp((suppTemp==i))=j;
                %% Solve GN with given support
                xTemp=DGN(w,suppTemp,c,n,x_k(suppTemp),iterations,F);
                fTemp=objectiveFun(w,c,xTemp);
                replacements=replacements+1;
                if fTemp<fMin
                    if (verbose)
                        fprintf('replacement: %d  Replacing %d with %d   f= %3.3f\n',replacements-1,i,j,fTemp);
                    end  
                    x_k=xTemp;
                    x_n=x_k;
                    supp=suppTemp;
                    improved=1;  
                    fMin=fTemp;
                    if fTemp<thresh
                        if (verbose) fprintf('******************************************Success!, iteration=%d\n',replacements);end
                        return;
                    end
                    break;
                else
                    x_n=xTemp;
                end
                if (replacementsSoFar+replacements+1>totalReplacements)
                    return
                end
            end
            if (improved) 
                break;
            end
        end
        if (~improved)
            if (verbose)
                fprintf('no possible improvement - trying new initial guess\n');
            end
            x_n=x_k;
            return                
        end
    end
    x_n=x_k;
end
        
    
    




