function [cov3,covSII]=eb_3LevelCovary(sigcov,sigMSx,thr)
% Function to compute the average covariance at low, mid, and high levels
% using the BM motion output by the cochlear model. The reference signal is
% assumed to be clean speech (no amplification) processed through a normal
% cochlea. The calculation averages the normalized covariance values in
% each  frequency band over the segments assigned to each of the three
% level regions. The level regions are based on a histogram of the
% reference signal intensity for the broadband sum over bands once the
% silent intervals have been removed. The histogram is divided into thirds.
%
% Calling arguments:
% sigcov    matrix [nchan,nseg] of cross-covariance values
% sigMSx    matrix [nchan,nseg] of reference signal MS values
% thr       threshold in dB SL to include segment in average
%
% Returned values:
% cov3	    average cross-covariance at each level [low,mid,high]
% covSII    average cross-covariance with SII weights
%
% James M. Kates, 28 August 2012.
% Adjusted for BM vibration in dB SL, 30 October 2012.
% Corrections in applying weights, 30 January 2013.

% Initialize the processing parameters for the SII calculation
cov3=zeros(3,1);
covSII=cov3;
nbands=size(sigcov,1);

% Find the segments that lie sufficiently above the threshold.
sigRMS=sqrt(sigMSx); %Convert squared amplitude to dB envelope
sigLinear=10.^(sigRMS/20); %Linear amplitude (specific loudness)
xsum=sum(sigLinear,1)/nbands; %Intensity averaged over frequency bands
xsum=20*log10(xsum); %Convert back to dB (loudness in phons)
index=find(xsum > thr); %Identify those segments above threshold
nseg=length(index); %Number of segments above threshold

% Exit if not enough segments above zero
if nseg <= 1
	fprintf('Function eb_3LevelCovary: Signal below threshold, outputs set to 0.\n');
	return;
end

% ---------------------------------------
% Initialize the SII importance function for the critical band procedure
% Critical band center frequencies in Hz
cfSII=[150 250 350 450 570 700 840 1000 1170 1370 1600 1850 2150 ...
	2500 2900 3400 4000 4800 5800 7000 8500];
% Weights for the Speech Intelligibility Index calculation
wgtSII=[.0103 .0261 .0419 .0577 .0577 .0577 .0577 .0577 .0577 .0577  ...
	 .0577 .0577 .0577 .0577 .0577 .0577 .0577 .0460 .0343 .0226 .0110];

% Interpolate the SII values for the remaining frequency bands
cfreq=eb_CenterFreq(nbands); %Center frequencies in Hz on an ERB scale
fsamp=24000; %Sampling rate in Hz
cfSII=[0 cfSII fsamp]; %Add the frequency extrema to the vectors
wgtSII=[0 wgtSII 0];
wfreq=interp1(cfSII,wgtSII,cfreq,'spline'); %Cubic spline interpolation

% Remove frequency bands below the SII range for SII weighting
wfreq(1)=0.0; %80 Hz
wfreq(2)=0.0; %115 Hz

% Weight the average covariance values by the SII importance function
wfreq=wfreq/sum(wfreq); %Normalize interpolated value sum to 1

% ---------------------------------------
% Remove the silent segments
sigcov=sigcov(:,index);
sigRMS=sigRMS(:,index);
xsum=xsum(index);

% Histogram of the segment intensities in phons
dBmin=min(xsum);
dBmax=max(xsum);
dBstep=0.5; %Bin width is 0.5 dB
bins=dBmin:dBstep:dBmax; %Histogram bin centers
[xhist,bincenters]=hist(xsum,bins); %Compute the histogram
nbins=length(xhist);

% Compute the cumulative histogram
xcum=zeros(nbins,1);
xcum(1)=xhist(1);
for k=2:nbins
    xcum(k)=xcum(k-1) + xhist(k);
end
xcum=xcum/xcum(nbins); %Normalize to give range of 0 to 1

% Find the boundaries for the lower, middle, and upper thirds
edge=zeros(2,1);
for n=1:nbins
   if xcum(n) < 0.333; edge(1)=bincenters(n); end;
   if xcum(n) < 0.667; edge(2)=bincenters(n); end;
end

% Assign segments to the lower, middle, and upper thirds
low=find(xsum < edge(1)); %Segment indices for lower third
mid=find((xsum >= edge(1)) & (xsum < edge(2)));
up=find(xsum >= edge(2));

% Compute the time-frequency weights. The weight=1 if a segment in a
% frequency band is above threshold, and weight=0 if at or below threshold.
weight=zeros(nbands,nseg);
for k=1:nbands
    for n=1:nseg
        if sigRMS(k,n) > thr; 
            weight(k,n)=1;
        end
    end
end
sigcov=weight.*sigcov; %Apply the weights

% Average the covariance across segment levels as a function of frequency
cov_ave=zeros(nbands,1); %Initialize average covariance
cov_ave_SII=cov_ave; %Initialize SII weighted covariance

% Low-level segments
s=sigcov(:,low); %Segment covariances for the low intensity
w=weight(:,low); %Low intensity time-freq segments above threshold
ssum=sum(s,2); %Sum over the low-intensity segments in each frequency band
wsum=sum(w,2); %Sum of the above-threshold weights in each frequency band
ncount=0;
wgtsum=0;
for n=1:nbands
    if(wsum(n) == 0)
        cov_ave(n)=0;
        cov_ave_SII(n)=0;
    else
        cov_ave(n)=ssum(n)/wsum(n);
        cov_ave_SII(n)=cov_ave(n)*wfreq(n);
        wgtsum=wgtsum + wfreq(n);
        ncount=ncount + 1;
    end
end
cov3(1)=sum(cov_ave)/ncount;
covSII(1)=sum(cov_ave_SII)/wgtsum;

% Mid-level segments
s=sigcov(:,mid);
w=weight(:,mid);
ssum=sum(s,2);
wsum=sum(w,2);
ncount=0;
wgtsum=0;
for n=1:nbands
    if(wsum(n) == 0)
        cov_ave(n)=0;
        cov_ave_SII(n)=0;
    else
        cov_ave(n)=ssum(n)/wsum(n);
        cov_ave_SII(n)=cov_ave(n)*wfreq(n);
        wgtsum=wgtsum + wfreq(n);
        ncount=ncount + 1;
    end
end
cov3(2)=sum(cov_ave)/ncount;
covSII(2)=sum(cov_ave_SII)/wgtsum;

% High-level segments
s=sigcov(:,up);
w=weight(:,up);
ssum=sum(s,2);
wsum=sum(w,2);
ncount=0;
wgtsum=0;
for n=1:nbands
    if(wsum(n) == 0)
        cov_ave(n)=0;
        cov_ave_SII(n)=0;
    else
        cov_ave(n)=ssum(n)/wsum(n);
        cov_ave_SII(n)=cov_ave(n)*wfreq(n);
        wgtsum=wgtsum + wfreq(n);
        ncount=ncount + 1;
    end
end
cov3(3)=sum(cov_ave)/ncount;
covSII(3)=sum(cov_ave_SII)/wgtsum;

end

