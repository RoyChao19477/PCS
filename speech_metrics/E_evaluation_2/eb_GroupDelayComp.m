function yenv=eb_GroupDelayComp(xenv,BW,cfreq,fsamp)
% Function to compensate for the group delay of the gammatone filter bank.
% The group delay is computed for each filter at its center frequency. The
% firing rate output of the IHC model is then adjusted so that all outputs
% have the same group delay.
%
% Calling variables:
% xenv     matrix of signal envelopes or BM motion
% BW       gammatone filter bandwidths adjusted for loss
% cfreq    center frequencies of the bands
% fsamp    sampling rate for the input signal in Hz (e.g. 24,000 Hz)
%
% Returned values:
% yenv    envelopes or BM motion compensated for the group delay
%
% James M. Kates, 28 October 2011.

% Processing parameters
nchan=length(BW);

% Filter ERB from Moore and Glasberg (1983)
earQ=9.26449;
minBW=24.7;
ERB=minBW + (cfreq/earQ);    

% Initialize the gamatone filter coefficients
tpt=2*pi/fsamp;
tptBW=tpt*1.019*BW.*ERB;
a=exp(-tptBW);
a1=4.0*a;
a2=-6.0*a.*a;
a3=4.0*a.*a.*a;
a4=-a.*a.*a.*a;
a5=4.0*a.*a;

% Compute the group delay in samples at fsamp for each filter
gd=zeros(nchan,1);
for n=1:nchan
    gd(n)=grpdelay([1 a1(n) a5(n)],[1 -a1(n) -a2(n) -a3(n) -a4(n)],1);
end
gd=round(gd); %Convert to integer samples

% Compute the delay correction
gmin=min(gd);
gd=gd - gmin; %Remove the minimum delay from all of the values
gmax=max(gd); %Maximum of the adjusted delay
correct=gmax - gd; %Samples delay needed to add to give alignment

% Add the delay correction to each frequency band
yenv=zeros(size(xenv)); %Allocate space for the output
for n=1:nchan
    r=xenv(n,:); %Extract the IHC firing rate
    npts=length(r);
    r=[zeros(1,correct(n)) r(1:npts-correct(n))];
    yenv(n,:)=r;
end
