function [y,b]=eb_EnvCompressBM(envsig,bm,control,attnOHC,thrLow,CR,fsamp,Level1)
% Function to compute the cochlear compression in one auditory filter
% band. The gain is linear below the lower threshold, compressive with
% a compression ratio of CR:1 between the lower and upper thresholds,
% and reverts to linear above the upper threshold. The compressor
% assumes that auditory thresold is 0 dB SPL.
%
% Calling variables:
% envsig	analytic signal envelope (magnitude) returned by the 
%			gammatone filter bank
% bm        BM motion output by the filter bank
% control	analytic control envelope returned by the wide control
%			path filter bank
% attnOHC	OHC attenuation at the input to the compressor
% thrLow	kneepoint for the low-level linear amplification
% CR		compression ratio
% fsamp		sampling rate in Hz
% Level1	dB reference level: a signal having an RMS value of 1 is
%			assigned to Level1 dB SPL.
%
% Function outputs:
% y			compressed version of the signal envelope
% b         compressed version of the BM motion
%
% James M. Kates, 19 January 2007.
% LP filter added 15 Feb 2007 (Ref: Zhang et al., 2001)
% Version to compress the envelope, 20 Feb 2007.
% Change in the OHC I/O function, 9 March 2007.
% Two-tone suppression added 22 August 2008.

% Initialize the compression parameters
thrHigh=100.0; %Upper compression threshold

% Convert the control envelope to dB SPL
small=1.0e-30;
logenv=max(control,small); %Don't want to take logarithm of zero or neg
logenv=Level1 + 20*log10(logenv);
logenv=min(logenv,thrHigh); %Clip signal levels above the upper threshold
logenv=max(logenv,thrLow); %Clip signal at the lower threshold

% Compute the compression gain in dB
gain=-attnOHC - (logenv - thrLow)*(1 - (1/CR));

% Convert the gain to linear and apply a LP filter to give a 0.2 msec delay
gain=10.^(gain/20);
flp=800;
[b,a]=butter(1,flp/(0.5*fsamp));
gain=filter(b,a,gain);

% Apply the gain to the signals
y=gain.*envsig; %Linear envelope
b=gain.*bm; %BM motion
