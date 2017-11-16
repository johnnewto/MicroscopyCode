% This scripts runs a 1D Fourier GESPAR simulation:
% It generates random vectors and tries to recover them from their (possibly noisy) 1D Fourier magnitude measurements, with x2 oversampling. 
% 
% Important parameters:
% n= number of measurements.  The length of the signal will be n/2
% kVec = range of simulated sparsity levels
% maxIt = Simulation iterations, for each k
% totIterations = Number of replacements allowed per signal
% snr = noise added to measurements.  1000 and above is treated as noiseless. Below 1000 no autocorrelation-derived support information will be used

clear;
close all;
warning on;
% Seeding random generator
s = RandStream('mcg16807','Seed',0);
RandStream.setGlobalStream(s);
kVec=2:1:8; % Range of sparsity values in simulations
n=128; % Number of measurements.  The length of the signal will be n/2
kInd=0;   
iterations=100; % GN inner iterations
draw=1;
verbose=0;
maxIt=10; % Simulation iterations, for each k
errMat=zeros(length(kVec),maxIt);
itMat=errMat;
trialsMat=errMat;
timeMat=errMat;
totIterations=6400; % Number of replacements allowed per signal
failedCases=[];
failInd=0;
recData=zeros(length(kVec),maxIt,n);
trueData=zeros(length(kVec),maxIt,n);
snr=1001; % snr>1000 is treated as noiseless
%% Run iterations
for k=kVec
    kInd=kInd+1;
    for it=1:maxIt
        tic
        success=0;
        %% Generating random data + measurements
        [F,x_real,c]=generate_fft_problem_function_oversampling(n/2,k);
        %% Calculating autocorrelation - Adding noise and symmetrizing c due to noise to get a real autocorrelation function
        cn=awgn(c,snr,'measured');
        cn=0.5*(cn+[cn(1);cn(end:-1:2)]);
        ac=(ifft(cn));
        ac=ac(1:n/2);

        %%
        locs=find(x_real);
        supp=locs'-min(locs)'+1;
        x_real=[x_real;zeros(n/2,1)];
        trueData(kInd,it,:)=x_real;
        itSoFar=0;
        trial=0;
        fValueMin=inf;
        while (itSoFar<totIterations)
            if (verbose)
                fprintf('total replacements so far = %d \n',itSoFar);
            end
            %% using GESPAR to recover x from cn (noisy measurements)
           noisy=1;
           fThresh=1e-3;
           randomWeights=1;
           [x_n,fValue,its]=GESPAR_1DF(cn,n/2,k,iterations,verbose,F,ac,noisy,itSoFar,totIterations,fThresh,randomWeights);
           trial=trial+1;
           itSoFar=itSoFar+its;
           if (fValue<2*norm(c-cn)^2 || fValue<1e-4) % Breaking condition for a successful recovery
               t=round(toc*100)/100;
               success=1;
               fValueMin=fValue;
               x_n_best=x_n;
               fprintf('%d. succeeded! k = %d   total evaluations %d  in %d initial points took %2.2f secs\n',it,k,itSoFar,trial,t);
             break;
           end
            if (fValue<fValueMin)
               fValueMin=fValue;
               x_n_best=x_n;
           end

        end
        if (~success)
            t=round(toc*100)/100;
            fprintf('%d. k = %d   %d Evaluations that took %2.2f secs were not enough\n',it,k,itSoFar,t);
            failInd=failInd+1;
            failedCases{failInd,1}=x_real;
        end
        x_nB=bestMatch(x_n_best,x_real);
        errMat(kInd,it)=norm(x_nB-x_real)/norm(x_real);
        itMat(kInd,it)=itSoFar;
        recData(kInd,it,:)=x_nB;
        trialsMat(kInd,it)=trial;
        t=toc;
        timeMat(kInd,it)=t;

%         if(draw)
%             figure(13); plot(1:n,x_nB,1:n,x_real,'*');pause;
%         end
    end
    l2erVec=mean(errMat,2);
    erMat=errMat;
    erMat(erMat<1e-3)=0;
    erMat(erMat>1e-3)=1;
    erVec=sum(erMat,2);
    timeVec=mean(timeMat,2);
    %% Saving Data
    fprintf('\n SAVING... \n',fValueMin);
    fileName=['GESPAR_results_snr_' num2str(snr)];
    save(fileName,'errMat','erVec','kVec','snr','n','totIterations','recData','trueData','l2erVec','maxIt','timeMat','timeVec','itMat','trialsMat');
end

%% Plotting
if (draw)
    figure;subplot(3,1,1);plot(kVec,(1-erVec/maxIt),'-*');title(['Recovery probability, N=' num2str(n)]);xlabel('k');ylim([0 1.1]);ylabel('Recovery probability');
    itVec=mean(itMat,2);
    subplot(3,1,2);plot(kVec,itVec,'-*');title('mean # of iterations vs k');xlabel('k');ylabel('Iterations');
    trialsVec=mean(trialsMat,2);
    subplot(3,1,3);plot(kVec,trialsVec,'-*');title('mean # of trials vs k');xlabel('k');ylabel('Trials');
    figure;plot(kVec,l2erVec);xlabel('k');ylabel('l2 error');title('mean l2 rec. error');
end



