function cf=eb_CenterFreq(nchan,shift)
% Function to compute the ERB frequency spacing for the gammatone
% filter bank. The equation comes from Malcolm Slaney (1993).
%
% Calling variables
% nchan		number of filters in the filter bank
% shift     optional frequency shift of the filter bank specified as a
%           fractional shift in distance along the BM. A positive shift
%           is an increase in frequency (basal shift), and negative is
%           a decrease in frequency (apical shift). The total length of
%           the BM is normalized to 1. The frequency-to-distance map is
%           from D.D. Greenwood (1990), JASA 87, 2592-2605, Eq (1).
%
% James M. Kates, 25 January 2007.
% Frequency shift added 22 August 2008.
% Lower and upper frequencies fixed at 80 and 8000 Hz, 19 June 2012.

% Parameters for the filter bank
lowFreq=80.0; %Lowest center frequency
highFreq=8000.0; %Highest center frequency

% Moore and Glasberg ERB values
EarQ = 9.26449;
minBW = 24.7;

% Frequency shift is an optional parameter
if nargin > 3
    k=1;
    A=165.4;
    a=2.1; %shift specified as a fraction of the total length
%   Locations of the low and high frequencies on the BM between 0 and 1
    xLow=(1/a)*log10(k + (lowFreq/A));
    xHigh=(1/a)*log10(k + (highFreq/A));
%   Shift the locations
    xLow=xLow*(1 + shift);
    xHigh=xHigh*(1 + shift);
%   Compute the new frequency range
    lowFreq=A*(10^(a*xLow) - k);
    highFreq=A*(10^(a*xHigh) - k);
end

% All of the following expressions are derived in Apple TR #35, "An
% Efficient Implementation of the Patterson-Holdsworth Cochlear
% Filter Bank" by Malcolm Slaney.
cf = -(EarQ*minBW)+exp((1:nchan-1)'*(-log(highFreq + EarQ*minBW) + ...
log(lowFreq + EarQ*minBW))/(nchan-1))*(highFreq + EarQ*minBW);
cf=[highFreq; cf]; %Last center frequency is set to highFreq
cf=flipud(cf); %Reorder to put the low frequencies first
