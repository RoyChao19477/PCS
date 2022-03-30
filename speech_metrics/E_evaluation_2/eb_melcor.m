function [m1,xy]=eb_melcor(x,y,thr,addnoise)
% Function to compute the cross-correlations between the input signal
% time-frequency envelope and the distortion time-frequency envelope. For
% each time interval, the log spectrum is fitted with a set of half-cosine
% basis functions. The spectrum weighted by the basis functions corresponds
% to mel cepstral coefficients computed in the frequency domain. The 
% amplitude-normalized cross-covariance between the time-varying basis
% functions for the input and output signals is then computed.
%
% Calling variables:
% x		    subsampled input signal envelope in dB SL in each critical band
% y		    subsampled distorted output signal envelope
% thr	    threshold in dB SPL to include segment in calculation
% addnoise  additive Gaussian noise to ensure 0 cross-corr at low levels
%
% Output:
% m1		average cepstral correlation 2-6, input vs output
% xy		individual cepstral correlations, input vs output
%
% James M. Kates, 24 October 2006.
% Difference signal removed for cochlear model, 31 January 2007.
% Absolute value added 13 May 2011.
% Changed to loudness criterion for silence threhsold, 28 August 2012.

% Processing parameters
nbands=size(x,1);

% Mel cepstrum basis functions (mel cepstrum because of auditory bands)
nbasis=6; %Number of cepstral coefficients to be used
freq=0:nbasis-1;
k=0:nbands-1;
cepm=zeros(nbands,nbasis);
for nb=1:nbasis
	basis=cos(freq(nb)*pi*k/(nbands-1));
	cepm(:,nb)=basis/norm(basis);
end

% Find the segments that lie sufficiently above the quiescent rate
xLinear=10.^(x/20); %Convert envelope dB to linear (specific loudness)
xsum=sum(xLinear,1)/nbands; %Proportional to loudness in sones
xsum=20*log10(xsum); %Convert back to dB (loudness in phons)
index=find(xsum > thr); %Identify those segments above threshold
nsamp=length(index); %Number of segments above threshold

% Exit if not enough segments above zero
if nsamp <= 1
	m1=0;
	xy=zeros(nbasis,1);
	fprintf('Function eb_melcor: Signal below threshold, outputs set to 0.\n');
	return;
end

% Remove the silent intervals
x=x(:,index);
y=y(:,index);

% Add the low-level noise to the envelopes
x=x + addnoise*randn(size(x));
y=y + addnoise*randn(size(y));

% Compute the mel cepstrum coefficients using only those segments
% above threshold
xcep=zeros(nbasis,nsamp); %Input
ycep=zeros(nbasis,nsamp); %Output
for n=1:nsamp
	for k=1:nbasis
		xcep(k,n)=sum(x(:,n).*cepm(:,k));
		ycep(k,n)=sum(y(:,n).*cepm(:,k));
	end
end

% Remove the average value from the cepstral coefficients. The
% cross-correlation thus becomes a cross-covariance, and there
% is no effect of the absolute signal level in dB.
for k=1:nbasis
	xcep(k,:)=xcep(k,:) - mean(xcep(k,:));
	ycep(k,:)=ycep(k,:) - mean(ycep(k,:));
end

% Normalized cross-correlations between the time-varying cepstral coeff
xy=zeros(nbasis,1); %Input vs output
small=1.0e-30;
for k=1:nbasis
	xsum=sum(xcep(k,:).^2);
	ysum=sum(ycep(k,:).^2);
	if (xsum < small) || (ysum < small)
		xy(k)=0.0;
	else
		xy(k)=abs(sum(xcep(k,:).*ycep(k,:))/sqrt(xsum*ysum));
	end
end

% Figure of merit is the average of the cepstral correlations, ignoring
% the first (average spectrum level).
m1=sum(xy(2:nbasis))/(nbasis-1);
