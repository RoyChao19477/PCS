function xdB=eb_aveSL(env,control,attnOHC,thrLow,CR,attnIHC,Level1)
% Function to covert the RMS average output of the gammatone filter bank
% into dB SL. The gain is linear below the lower threshold, compressive
% with a compression ratio of CR:1 between the lower and upper thresholds,
% and reverts to linear above the upper threshold. The compressor
% assumes that auditory thresold is 0 dB SPL.
%
% Calling variables:
% env		analytic signal envelope (magnitude) returned by the 
%			gammatone filter bank, RMS average level
% control   control signal envelope
% attnOHC	OHC attenuation at the input to the compressor
% thrLow	kneepoint for the low-level linear amplification
% CR		compression ratio
% attnIHC	IHC attenuation at the input to the synapse
% Level1	dB reference level: a signal having an RMS value of 1 is
%			assigned to Level1 dB SPL.
%
% Function output:
% xdB		compressed output in dB above the impaired threshold
%
% James M. Kates, 6 August 2007.
% Version for two-tone suppression, 29 August 2008.

% Initialize the compression parameters
thrHigh=100.0; %Upper compression threshold

% Convert the control to dB SPL
small=1.0e-30;
logenv=max(control,small); %Don't want to take logarithm of zero or neg
logenv=Level1 + 20*log10(logenv);
logenv=min(logenv,thrHigh); %Clip signal levels above the upper threshold
logenv=max(logenv,thrLow); %Clip signal at the lower threshold

% Compute the compression gain in dB
gain=-attnOHC - (logenv - thrLow).*(1 - (1./CR)); %Gain in dB

% Convert the signal envelope to dB SPL
logenv=max(env,small); %Don't want to take logarithm of zero or neg
logenv=Level1 + 20*log10(logenv);
logenv=max(logenv,0); %Clip signal at auditory threshold
xdB=logenv + gain - attnIHC; %Apply gain to the log spectrum
xdB=max(xdB,0.0); %dB SL
