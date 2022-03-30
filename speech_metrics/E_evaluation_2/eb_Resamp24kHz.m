function [y,fsamp]=eb_Resamp24kHz(x,fsampx)
% Function to resample the input signal at 24 kHz. The input sampling rate
% is rounded to the nearest kHz to comput the sampling rate conversion
% ratio.
%
% Calling variables:
% x         input signal
% fsampx    sampling rate for the input in Hz
%
% Returned argument:
% y         signal resampled at 24 kHz
% fsamp     output sampling rate in Kz
%
% James M. Kates, 20 June 2011.

% Sampling rate information
fsamp=24000; %Output sampling rate in Hz
fy=round(fsamp/1000); %Ouptut rate in kHz
fx=round(fsampx/1000); %Input rate to nearest kHz

% Resample the signal
if fx == fy
%   No resampling performed if the rates match
    y=x;

elseif fx < fy
%   Resample for the input rate lower than the output
    y=resample(x,fy,fx);
    
%   Match the RMS level of the resampled signal to that of the input
    xRMS=sqrt(mean(x.^2));
    yRMS=sqrt(mean(y.^2));
    y=(xRMS/yRMS)*y;
  
else
%   Resample for the input rate higher than the output
%   Resampling includes an anti-aliasing filter.
    y=resample(x,fy,fx);
    
%   Reduce the input signal bandwidth to 21 kHz:
%   Chebychev Type 2 LP (smooth passband)
    order=7; %Filter order
    atten=30; %Sidelobe attenuation in dB
    fcutx=21/fx; %Cutoff frequency as a fraction of the sampling rate
    [bx,ax]=cheby2(order,atten,fcutx);
    xfilt=filter(bx,ax,x);
    
%   Reduce the resampled signal bandwidth to 21 kHz
    fcuty=21/fy;
    [by,ay]=cheby2(order,atten,fcuty);
    yfilt=filter(by,ay,y);
    
%   Compute the input and output RMS levels within the 21 kHz bandwidth
%   and match the output to the input
    xRMS=sqrt(mean(xfilt.^2));
    yRMS=sqrt(mean(yfilt.^2));  
    y=(xRMS/yRMS)*y;
end
