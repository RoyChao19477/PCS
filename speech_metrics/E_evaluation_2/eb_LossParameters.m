function [attnOHC,BW,lowknee,CR,attnIHC]=eb_LossParameters(HL,cfreq)
% Function to apportion the hearing loss to the outer hair cells (OHC)
% and the inner hair cells (IHC) and to increase the bandwidth of the
% cochlear filters in proportion to the OHC fraction of the total loss.
%
% Calling variables:
% HL		hearing loss at the 6 audiometric frequencies
% cfreq		array containing the center frequencies of the gammatone filters
%			arranged from low to high
%
% Returned values:
% attnOHC	attenuation in dB for the OHC gammatone filters
% BW		OHC filter bandwidth expressed in terms of normal
% lowknee	Lower kneepoint for the low-level linear amplification
% CR		Ranges from 1.4:1 at 150 Hz to 3.5:1 at 8 kHz for normal
%			hearing. Reduced in proportion to the OHC loss to 1:1.
% attnIHC	attenuation in dB for the input to the IHC synapse
%
% James M. Kates, 25 January 2007.
% Version for loss in dB and match of OHC loss to CR, 9 March 2007.
% Low-frequency extent changed to 80 Hz, 27 Oct 2011.
% Lower kneepoint set to 30 dB, 19 June 2012.

% Audiometric frequencies in Hz
aud=[250, 500, 1000, 2000, 4000, 6000];

% Interpolation to give the loss at the gammatone center frequencies
% Use linear interpolation in dB. The interpolation assumes that
% cfreq(1) < aud(1) and cfreq(nfilt) > aud(6)
nfilt=length(cfreq); %Number of filters in the filter bank
fv=[cfreq(1),aud,cfreq(nfilt)]; %Frequency vector for the interpolation
loss=interp1(fv,[HL(1),HL,HL(6)],cfreq); %Interpolated gain in dB
loss=max(loss,0); %Make sure there are no negative losses

% Compression ratio changes linearly with ERB rate from 1.25:1 in 
% the 80-Hz frequency band to 3.5:1 in the 8-kHz frequency band
CR=zeros(nfilt,1);
for n=1:nfilt
    CR(n)=1.25 + 2.25*(n-1)/(nfilt-1);
end

% Maximum OHC sensitivity loss depends on the compression ratio.
% The compression I/O curves assume linear below 30 and above 100
% dB SPL in normal ears.
maxOHC=70*(1 - (1./CR)); %OHC loss that results in 1:1 compression
thrOHC=1.25*maxOHC; %Loss threshold for adjusting the OHC parameters

% Apportion the loss in dB to the outer and inner hair cells based on
% the data of Moore et al (1999), JASA 106, 2761-2778. Reduce the CR
% towards 1:1 in proportion to the OHC loss.
attnOHC=zeros(nfilt,1); %Default is 0 dB attenuation
attnIHC=zeros(nfilt,1);
for n=1:nfilt
	if loss(n) < thrOHC(n)
		attnOHC(n)=0.8*loss(n);
		attnIHC(n)=0.2*loss(n);
	else
		attnOHC(n)=0.8*thrOHC(n); %Maximum OHC attenuation
		attnIHC(n)=0.2*thrOHC(n) + (loss(n)-thrOHC(n));
	end
end

% Adjust the OHC bandwidth in proportion to the OHC loss
BW=ones(nfilt,1); %Default is normal hearing gammatone bandwidth
BW=BW + (attnOHC/50.0) + 2.0*(attnOHC/50.0).^6;

% Compute the compression lower kneepoint and compression ratio
lowknee=attnOHC + 30; % Lower kneepoint
upamp=30 + 70./CR; %Output level for an input of 100 dB SPL
CR=(100-lowknee)./(upamp + attnOHC - lowknee); %OHC loss Compression ratio
