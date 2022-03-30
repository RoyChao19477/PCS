function [Intel,raw] = HASPI_v1(x,fx,y,fy,HL,Level1)
% Function to compute the HASPI intelligibility index using the 
% auditory model followed by computing the envelope cepstral
% correlation and BM vibration high-level covariance. The reference
% signal presentation level for NH listeners is assumed to be 65 dB
% SPL. The same model is used for both normal and impaired hearing.
%
% Calling arguments:
% x			Clear input reference speech signal with no noise or distortion. 
%           If a hearing loss is specified, no amplification should be provided.
% fx        Sampling rate in Hz for signal x
% y			Output signal with noise, distortion, HA gain, and/or processing.
% fy        Sampling rate in Hz for signal y.
% HL		(1,6) vector of hearing loss at the 6 audiometric frequencies
%			  [250, 500, 1000, 2000, 4000, 6000] Hz.
% Level1    Optional input specifying level in dB SPL that corresponds to a
%           signal RMS = 1. Default is 65 dB SPL if argument not provided.
%
% Returned values:
% Intel     Cepstral correlation and three-level temporal fine structure 
%           covariance transformed into the estimated intelligibility
%           between 0 and 1 inclusive. The transformation is based on the
%           average of the NH and HI subjects scored on all available data.
% raw       [CepCorr, cov3]  Raw cepstral correlation output plus 
%           raw 3-level covariance values [low,mid,high]; only high is used.
%
% James M. Kates, 5 August 2013.

% Set the RMS reference level
if nargin < 6
    Level1=65;
end

% Auditory model for intelligibility
% Reference is no processing, normal hearing
itype=0; %Intelligibility model
[xenv,xBM,yenv,yBM,xSL,ySL,fsamp]=...
    eb_EarModel(x,fx,y,fy,HL,itype,Level1);

% ---------------------------------------
% Smooth the envelope outputs: 125 Hz sub-sampling rate
segsize=16; %Averaging segment size in msec
xdB=eb_EnvSmooth(xenv,segsize,fsamp);
ydB=eb_EnvSmooth(yenv,segsize,fsamp);

% Mel cepstrum correlation using smoothed envelopes
% m1=ave of coefficients 2-6
% xy=vector of coefficients 1-6
thr=2.5; %Silence threshold: sum across bands, dB above aud threshold
addnoise=0.0; %Additive noise in dB SL to condition cross-covariances
[CepCorr,xy]=eb_melcor(xdB,ydB,thr,addnoise);

% ---------------------------------------
% Temporal fine structure correlation measurements
% Compute the time-frequency segment covariances
segcov=16; %Segment size for the covariance calculation
[sigcov,sigMSx,sigMSy]=eb_BMcovary(xBM,yBM,segcov,fsamp);

% Three-level signal segment covariance
% cov3 vector:   [low, mid, high] intensity region average, uniform weights
% covSII vector: [low, mid, high] with SII frequency band weights
[cov3,covSII]=eb_3LevelCovary(sigcov,sigMSx,thr);

% ---------------------------------------
% Intelligibility prediction
% Combine the cepstral correlation and three-level covariance
bias=-9.047;
wgtcep=14.816;
wgtcov=[0, 0, 4.616]; %[low, mid, high]
arg=bias + wgtcep*CepCorr + sum(wgtcov.*cov3');

% Logsig transformation
Intel=1.0/(1.0 + exp(-arg)); %Logistic (logsig) function

% Raw data
raw=[CepCorr, cov3'];

end
