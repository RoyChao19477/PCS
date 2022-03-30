function [sigcov,sigMSx,sigMSy]=eb_BMcovary(xBM,yBM,segsize,fsamp)
% Function to compute the cross-covariance (normalized cross-correlation) 
% between the reference and processed signals in each auditory band. The
% signals are divided into segments having 50% overlap. 
%
% Calling arguments:
% xBM       BM movement, reference signal
% yBM       BM movement, processed signal
% segsize   signal segment size, msec
% fsamp     sampling rate in Hz
%
% Returned values:
% sigcov    matrix [nchan,nseg] of cross-covariance values
% sigMSx    matrix [nchan,nseg] of MS input signal energy values
% sigMSy    matrix [nchan,nseg] of MS processed signal energy values
%
% James M. Kates, 28 August 2012.
% Output amplitude adjustment added, 30 october 2012.

% Initialize parameters
small=1.0e-30;

% Lag for computing the cross-covariance
lagsize=1.0; %Lag (+/-) in msec
maxlag=round(lagsize*(0.001*fsamp)); %Lag in samples

% Compute the segment window
nwin=round(segsize*(0.001*fsamp)); %Segment size in samples
test=nwin - 2*floor(nwin/2); %0=even, 1=odd
if test>0; nwin=nwin+1; end; %Force window length to be even
window=hann(nwin)'; %Raised cosine von Hann window
wincorr=1./xcorr(window,window,maxlag); %Window autocorrelation, inverted
winsum2=1.0/sum(window.^2); %Window power, inverted

% The first segment has a half window
nhalf=nwin/2;
halfwindow=window(nhalf+1:nwin);
halfcorr=1./xcorr(halfwindow,halfwindow,maxlag);
halfsum2=1.0/sum(halfwindow.^2); %MS sum normalization, first segment

% Number of segments
nchan=size(xBM,1);
npts=size(xBM,2);
nseg=1 + floor(npts/nwin) + floor((npts-nwin/2)/nwin);
sigMSx=zeros(nchan,nseg);
sigMSy=sigMSx;
sigcov=sigMSx;

% Loop to compute the signal mean-squared level in each band for each
% segment and to compute the cross-corvariances.
for k=1:nchan
%	Extract the BM motion in the frequency band
	x=xBM(k,:);
    y=yBM(k,:);
    
%	The first (half) windowed segment
	nstart=1;
    segx=x(nstart:nhalf).*halfwindow; %Window the reference
    segy=y(nstart:nhalf).*halfwindow; %Window the processed signal
    segx=segx - mean(segx); %Make 0-mean
    segy=segy - mean(segy);
    MSx=sum(segx.^2)*halfsum2; %Normalize signal MS value by the window
    MSy=sum(segy.^2)*halfsum2;
    Mxy=max(abs(xcorr(segx,segy,maxlag).*halfcorr)); %Unbiased cross-correlation
    if (MSx > small) && (MSy > small)
        sigcov(k,1)=Mxy/sqrt(MSx*MSy); %Normalized cross-covariance
    else
        sigcov(k,1)=0.0;
    end
    sigMSx(k,1)=MSx; %Save the reference MS level
    sigMSy(k,1)=MSy;
    
%	Loop over the remaining full segments, 50% overlap
	for n=2:nseg-1
		nstart=nstart + nhalf;
		nstop=nstart + nwin - 1;
        segx=x(nstart:nstop).*window; %Window the reference
        segy=y(nstart:nstop).*window; %Window the processed signal
        segx=segx - mean(segx); %Make 0-mean
        segy=segy - mean(segy);
        MSx=sum(segx.^2)*winsum2; %Normalize signal MS value by the window
        MSy=sum(segy.^2)*winsum2;
        Mxy=max(abs(xcorr(segx,segy,maxlag).*wincorr)); %Unbiased cross-corr
        if (MSx > small) && (MSy > small)
            sigcov(k,n)=Mxy/sqrt(MSx*MSy); %Normalized cross-covariance
        else
            sigcov(k,n)=0.0;
        end
        sigMSx(k,n)=MSx; %Save the reference MS level
        sigMSy(k,n)=MSy; %Save the reference MS level
    end
    
%   The last (half) windowed segment
	nstart=nstart + nhalf;
	nstop=nstart + nhalf - 1;
    segx=x(nstart:nstop).*window(1:nhalf); %Window the reference
    segy=y(nstart:nstop).*window(1:nhalf); %Window the processed signal
    segx=segx - mean(segx); %Make 0-mean
    segy=segy - mean(segy);
    MSx=sum(segx.^2)*halfsum2; %Normalize signal MS value by the window
    MSy=sum(segy.^2)*halfsum2;
    Mxy=max(abs(xcorr(segx,segy,maxlag).*halfcorr)); %Unbiased cross-correlation
    if (MSx > small) && (MSy > small)
        sigcov(k,nseg)=Mxy/sqrt(MSx*MSy); %Normalized cross-covariance
    else
        sigcov(k,nseg)=0.0;
    end
    sigMSx(k,nseg)=MSx; %Save the reference MS level    
    sigMSy(k,nseg)=MSy; %Save the reference MS level
end

% Limit the cross-covariance to lie between 0 and 1
sigcov=max(sigcov,0);
sigcov=min(sigcov,1);

% Adjust the BM magnitude to correspond to the envelope in dB SL
sigMSx=2.0*sigMSx;
sigMSy=2.0*sigMSy;
end
