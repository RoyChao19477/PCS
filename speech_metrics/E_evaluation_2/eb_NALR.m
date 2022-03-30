function [nalr,delay]=eb_NALR(HL,nfir,fsamp)
% Function to design an FIR NAL-R equalization filter and a flat filter
% having the same linear-phase time delay.
%
% Calling variables:
% HL        Hearing loss at the audiometric frequencies
% nfir		Order of the NAL-R EQ filter and the matching delay
% fsamp     sampling rate in Hz
%
% Returned arrays:
% nalr		linear-phase filter giving the NAL-R gain function
% delay		pure delay equal to that of the NAL-R filter
%
% James M. Kates, 27 December 2006.
% Version for noise estimation system, 27 Oct 2011.

% Processing parameters
fmax=0.5*fsamp; %Nyquist frequency

% Audiometric frequencies
aud=[250, 500, 1000, 2000, 4000, 6000]; %Audiometric frequencies in Hz

% Design a flat filter having the same delay as the NAL-R filter
delay=zeros(1,nfir+1);
delay(1+nfir/2)=1.0;
    
% Design the NAL-R filter for HI listener
mloss=max(HL); %Test for hearing loss
if mloss > 0
%	Compute the NAL-R frequency response at the audiometric frequencies
	bias=[-17 -8 1 -1 -2 -2];
	t3=HL(2) + HL(3) + HL(4); %Three-frequency average loss
	if t3 <= 180
		xave=0.05*t3;
	else
		xave=9.0 + 0.116*(t3-180);
	end
	gdB=xave + 0.31*HL + bias;
	gdB=max(gdB,0); %Remove negative gains

%	Design the linear-phase FIR filter
	fv=[0,aud,fmax]; %Frequency vector for the interpolation
	cfreq=(0:nfir)/nfir; %Uniform frequency spacing from 0 to 1
	gain=interp1(fv,[gdB(1),gdB,gdB(6)],fmax*cfreq); %Interpolated gain in dB
	glin=10.^(gain/20.0); %Convert gain from dB to linear
	nalr=fir2(nfir,cfreq,glin); %Design the filter (length = nfir+1)
else
%	Filters for the normal-hearing subject
	nalr=delay;
end
