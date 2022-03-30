function xout=eb_MiddleEar(x,fsamp)
% Function to design the middle ear filters and process the input
% through the cascade of filters. The middle ear model is a 2-pole HP
% filter at 350 Hz in series with a 1-pole LP filter at 5000 Hz. The
% result is a rough approximation to the equal-loudness contour at
% threshold.
%
% Calling variables:
%	x		input signal
%	fsamp	sampling rate in Hz
%
% Function output:
%	xout	filtered output
%
% James M. Kates, 18 January 2007.

% Design the 1-pole Butterworth LP using the bilinear transformation
[bLP, aLP]=butter(1,5000/(0.5*fsamp)); %5000-Hz LP

% LP filter the input
y=filter(bLP,aLP,x);

% Design the 2-pole Butterworth HP using the bilinear transformation
[bHP,aHP]=butter(2,350/(0.5*fsamp),'high'); %350-Hz HP

% HP filter the signal
xout=filter(bHP,aHP,y);


