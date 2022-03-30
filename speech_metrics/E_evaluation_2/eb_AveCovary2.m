function [avecov,syncov]=eb_AveCovary2(sigcov,sigMSx,thr)
% Function to compute the average cross-covariance between the reference
% and processed signals in each auditory band. The silent time-frequency
% tiles are removed from consideration. The cross-covariance is computed
% for each segment in each frequency band. The values are weighted by 1
% for inclusion or 0 if the tile is below threshold. The sum of the
% covariance values across time and frequency are then divided by the total
% number of tiles above thresold. The calculation is a modification of
% Tan et al. (JAES 2004). The cross-covariance is also output with a
% frequency weighting that reflects the loss of IHC synchronization at high
% frequencies (Johnson, JASA 1980).
%
% Calling arguments:
% sigcov    matrix [nchan,nseg] of cross-covariance values
% sigMSx    matrix [nchan,nseg] of reference signal MS values
% thr       threshold in dB SL to include segment ave over freq in average
%
% Returned values:
% avecov	cross-covariance in segments averaged over time and frequency
% syncov    cross-coraviance array, 6 different weightings for loss of
%           IHC synchronization at high frequencies:
%           LP Filter Order     Cutoff Freq, kHz
%                 1              1.5
%                 3              2.0
%                 5              2.5, 3.0, 3.5, 4.0
%
% James M. Kates, 28 August 2012.
% Adjusted for BM vibration in dB SL, 30 October 2012.
% Threshold for including time-freq tile modified, 30 January 2013.
% Version for different sync loss, 15 February 2013.

% Array dimensions
nchan=size(sigcov,1);

% Initialize the LP filter for loss of IHC synchronization
cfreq=eb_CenterFreq(nchan); %Center frequencies in Hz on an ERB scale
p=        [1,   3,   5,   5,   5,   5  ]; %LP filter order
fcut=1000*[1.5, 2.0, 2.5, 3.0, 3.5, 4.0]; %Cutoff frequencies in Hz
fsync=zeros(6,nchan); %Array of filter freq resp vs band center freq
for n=1:6
    fc2p=fcut(n)^(2*p(n));
    freq2p=cfreq.^(2*p(n));
    fsync(n,:)=sqrt(fc2p./(fc2p + freq2p));
end

% Find the segments that lie sufficiently above the threshold.
sigRMS=sqrt(sigMSx); %Convert squared amplitude to dB envelope
sigLinear=10.^(sigRMS/20); %Linear amplitude (specific loudness)
xsum=sum(sigLinear,1)/nchan; %Intensity averaged over frequency bands
xsum=20*log10(xsum); %Convert back to dB (loudness in phons)
index=find(xsum > thr); %Identify those segments above threshold
nseg=length(index); %Number of segments above threshold

% Exit if not enough segments above zero
if nseg <= 1
	fprintf('Function eb_AveCovary: Ave signal below threshold, outputs set to 0.\n');
    avecov=0;
    syncov=0;
	return;
end

% ---------------------------------------
% Remove the silent segments
sigcov=sigcov(:,index);
sigRMS=sigRMS(:,index);

% Compute the time-frequency weights. The weight=1 if a segment in a
% frequency band is above threshold, and weight=0 if below threshold.
weight=zeros(nchan,nseg); %No IHC synchronization roll-off
wsync1=weight; %Loss of IHC synchronization at high frequencies
wsync2=weight;
wsync3=weight;
wsync4=weight;
wsync5=weight;
wsync6=weight;
for k=1:nchan
    for n=1:nseg
        if sigRMS(k,n) > thr %Thresh in dB SL for including time-freq tile
            weight(k,n)=1;
            wsync1(k,n)=fsync(1,k);
            wsync2(k,n)=fsync(2,k);
            wsync3(k,n)=fsync(3,k);
            wsync4(k,n)=fsync(4,k);
            wsync5(k,n)=fsync(5,k);
            wsync6(k,n)=fsync(6,k);
        end     
    end
end

% Sum the weighted covariance values
csum=sum(sum(weight.*sigcov)); %Sum of weighted time-freq tiles
wsum=sum(sum(weight)); %Total number of tiles above thresold
fsum=zeros(6,1);
ssum=fsum;
fsum(1)=sum(sum(wsync1.*sigcov)); %Sum of weighted time-freq tiles
ssum(1)=sum(sum(wsync1)); %Total number of tiles above thresold
fsum(2)=sum(sum(wsync2.*sigcov)); %Sum of weighted time-freq tiles
ssum(2)=sum(sum(wsync2)); %Total number of tiles above thresold
fsum(3)=sum(sum(wsync3.*sigcov)); %Sum of weighted time-freq tiles
ssum(3)=sum(sum(wsync3)); %Total number of tiles above thresold
fsum(4)=sum(sum(wsync4.*sigcov)); %Sum of weighted time-freq tiles
ssum(4)=sum(sum(wsync4)); %Total number of tiles above thresold
fsum(5)=sum(sum(wsync5.*sigcov)); %Sum of weighted time-freq tiles
ssum(5)=sum(sum(wsync5)); %Total number of tiles above thresold
fsum(6)=sum(sum(wsync6.*sigcov)); %Sum of weighted time-freq tiles
ssum(6)=sum(sum(wsync6)); %Total number of tiles above thresold

% Exit if not enough segments above zero
if wsum < 1
	avecov=0;
    syncov=fsum./ssum;
	fprintf('Function eb_AveCovary: Signal tiles below threshold, outputs set to 0.\n');
else
    avecov=csum/wsum;
    syncov=fsum./ssum;
end

end
