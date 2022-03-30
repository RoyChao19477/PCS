function y=eb_BMaddnoise(x,thr,Level1)
% Function to apply the IHC attenuation to the BM motion and to add a
% low-level Gaussian noise to give the auditory threshold.
%
% Calling arguments:
% x         BM motion to be attenuated
% thr       additive noise level in dB re:auditory threshold
% Level1    an input having RMS=1 corresponds to Leve1 dB SPL
%
% Returned values:
% y         attenuated signal with threhsold noise added
%
% James M. Kates, 19 June 2012.
% Just additive noise, 2 Oct 2012.

% Additive noise
gn=10^((thr - Level1)/20.0); %Linear gain for the noise
noise=gn*randn(size(x)); %Gaussian RMS=1, then attenuated
y=x + noise;

end
