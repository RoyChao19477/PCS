function [dloud,dnorm,dslope]=eb_SpectDiff(xSL,ySL)
% Function to compute changes in the long-term spectrum and spectral slope.
% The metric is based on the spectral distortion metric of Moore and Tan
% (JAES, Vol 52, pp 900-914). The log envelopes in dB SL are converted to
% linear to approximate specific loudness. The outputs are the sum of the 
% absolute differences, the standard deviation of the differences, and the
% maximum absolute difference. The same three outputs are provided for the
% normalized spectral difference and for the slope. The output is
% calibrated so that a processed signal having 0 amplitude produces a
% value of 1 for the spectrum difference.
%
% Abs diff: weight all deviations uniformly
% Std diff: weight larger deviations more than smaller deviations
% Max diff: only weight the largest deviation
%
% Calling arguments:
% xSL     reference signal spectrum in dB SL
% ySL     degraded signal spectrum in dB SL
%
% Returned values:
% dloud   vector: [sum abs diff, std dev diff, max diff] spectra
% dnorm   vector: [sum abs diff, std dev diff, max diff] norm spectra
% dslope  vector: [sum abs diff, std dev diff, max diff] slope
%
% James M. Kates, 28 June 2012.

% Convert the dB SL to linear magnitude values. Because of the auditory
% filter bank, the OHC compression, and auditory threshold, the linear
% values are closely related to specific loudness.
nbands=length(xSL);
x=10.^(xSL/20);
y=10.^(ySL/20);

% Normalize the level of the reference and degraded signals to have the
% same loudness. Thus overall level is ignored while differences in
% spectral shape are measured.
xsum=sum(x);
x=x/xsum; %Loudness sum = 1 (arbitrary amplitude, proportional to sones)
ysum=sum(y);
y=y/ysum;

% Compute the spectrum difference
dloud=zeros(3,1);
d=(x - y); %Difference in specific loudness in each band
dloud(1)=sum(abs(d));
dloud(2)=nbands*std(d,1); %Biased std: second moment
dloud(3)=max(abs(d));

% Compute the normalized spectrum difference
dnorm=zeros(3,1);
d=(x - y)./(x + y); %Relative difference in specific loudness
dnorm(1)=sum(abs(d));
dnorm(2)=nbands*std(d,1);
dnorm(3)=max(abs(d));

% Compute the slope difference
dslope=zeros(3,1);
dx=(x(2:nbands) - x(1:nbands-1));
dy=(y(2:nbands) - y(1:nbands-1));
d=dx - dy; %Slope difference
dslope(1)=sum(abs(d));
dslope(2)=nbands*std(d,1);
dslope(3)=max(abs(d));

end
