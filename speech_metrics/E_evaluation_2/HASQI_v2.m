function [Combined,Nonlin,Linear,raw] = HASQI_v2(x,fx,y,fy,HL,eq,Level1)
% Function to compute the HASQI version 2 quality index using the
% auditory model followed by computing the envelope cepstral
% correlation and BM vibration average short-time coherence signals.
% The reference signal presentation level for NH listeners is assumed
% to be 65 dB SPL. The same model is used for both normal and
% impaired hearing.
%
% Calling arguments:
% x			Clear input reference speech signal with no noise or distortion. 
%           If a hearing loss is specified, NAL-R equalization is optional
% fx        Sampling rate in Hz for signal x
% y			Output signal with noise, distortion, HA gain, and/or processing.
% fy        Sampling rate in Hz for signal y.
% HL		(1,6) vector of hearing loss at the 6 audiometric frequencies
%			  [250, 500, 1000, 2000, 4000, 6000] Hz.
% eq        Flag to provide equalization for the hearing loss to signal x:
%             1 = no EQ has been provided, the function will add NAL-R
%             2 = NAL-R EQ has already been added to the reference signal
% Level1    Optional input specifying level in dB SPL that corresponds to a
%           signal RMS = 1. Default is 65 dB SPL if argument not provided.
%
% Returned values:
% Combined  Quality estimate is the product of the nonlinear and linear terms
% Nonlin    Nonlinear quality component = (cepstral corr)^2 x seg BM coherence
% Linear    Linear quality component = std of spectrum and spectrum slope
% raw       Vector of raw values = [CepCorr, BMsync5, Dloud, Dslope]
%
% James M. Kates, 5 August 2013.

% Set the RMS reference level
if nargin < 7
    Level1=65;
end

% Auditory model for quality
% Reference is no processing or NAL-R, impaired hearing
[xenv,xBM,yenv,yBM,xSL,ySL,fsamp]=...
    eb_EarModel(x,fx,y,fy,HL,eq,Level1);

% ---------------------------------------
% Envelope and long-term average spectral features
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

% Linear changes in the log-term spectra
% dloud  vector: [sum abs diff, std dev diff, max diff] spectra
% dnorm  vector: [sum abs diff, std dev diff, max diff] norm spectra
% dslope vector: [sum abs diff, std dev diff, max diff] slope
[dloud,dnorm,dslope]=eb_SpectDiff(xSL,ySL);

% ---------------------------------------
% Temporal fine structure correlation measurements
% Compute the time-frequency segment covariances
segcov=16; %Segment size for the covariance calculation
[sigcov,sigMSx,sigMSy]=eb_BMcovary(xBM,yBM,segcov,fsamp);

% Average signal segment cross-covariance
% avecov=weighted ave of cross-covariances, using only data above threshold
% syncov=ave cross-covariance with added IHC loss of synchronization at HF
thr=2.5; %Threshold in dB SL for including time-freq tile
[avecov,syncov]=eb_AveCovary2(sigcov,sigMSx,thr);
BMsync5=syncov(5); %Ave segment coherence with IHC loss of sync

% Extract and normalize the spectral features
% Dloud:std
d=dloud(2); %Loudness difference std
d=d/2.5; %Scale the value
d=1.0 - d; %1=perfect, 0=bad
d=min(d,1);
d=max(d,0);
Dloud=d;

% Dslope:std
d=dslope(2); %Slope difference std
d=1.0 - d;
d=min(d,1);
d=max(d,0);
Dslope=d;

% ---------------------------------------
% Construct the models
% Nonlinear model
Nonlin=(CepCorr^2)*BMsync5; %Combined envelope and temporal fine structure

% Linear model
Linear=0.579*Dloud + 0.421*Dslope; %Linear fit

% Combined model
Combined=Nonlin*Linear; %Product of nonlinear x linear

% Raw data
raw=[CepCorr,BMsync5,Dloud,Dslope];

end

