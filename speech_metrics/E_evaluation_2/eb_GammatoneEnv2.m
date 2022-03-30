function [envx,envy]=eb_GammatoneEnv2(x,BWx,y,BWy,fs,cf)
% 4th-order gammatone auditory filter. This implementation is based
% on the c program published on-line by Ning Ma, U. Sheffield, UK,
% that gives an implementation of the Martin Cooke (1991) filters: 
% an impulse-invariant transformation of the gammatone filter. The 
% signal is demodulated down to baseband using a complex exponential,
% and then passed through a cascade of four one-pole low-pass filters.
%
% This version filters two signals that have the same sampling rate and the
% same gammatone filter center frequencies. The lengths of the two signals
% should match; if they don't, the signals are truncated to the shorter of
% the two lengths.
%
% Calling variables:
% x			first sequence to be filtered
% BWx	    bandwidth for x relative to that of a normal ear
% y			second sequence to be filtered
% BWy	    bandwidth for x relative to that of a normal ear
% fs		sampling rate in Hz
% cf		filter center frequency in Hz
%
% Returned values:
% envx      filter envelope output (modulated down to baseband) 1st signal
% envy      filter envelope output (modulated down to baseband) 2nd signal

% James M. Kates, 8 Jan 2007.
% Vectorized version for efficient MATLAB execution, 4 February 2007.
% Cosine and sine generation, 29 June 2011.
% Output sine and cosine sequences, 19 June 2012.
% Cosine/sine loop speed increased, 9 August 2013.

% Filter ERB from Moore and Glasberg (1983)
earQ=9.26449;
minBW=24.7;
ERB=minBW + (cf/earQ);

% Check the lengths of the two signals
nx=length(x);
ny=length(y);
nsamp=min(nx,ny);
x=x(1:nsamp);
y=y(1:nsamp);

% ---------------------------------------
% Filter the first signal
% Initialize the filter coefficients
tpt=2*pi/fs;
tptBW=BWx*tpt*ERB*1.019;
a=exp(-tptBW);
a1=4.0*a;
a2=-6.0*a*a;
a3=4.0*a*a*a;
a4=-a*a*a*a;
a5=4.0*a*a;
gain=2.0*(1-a1-a2-a3-a4)/(1+a1+a5);

% Initialize the complex demodulation
npts=length(x);
cn=cos(tpt*cf);
sn=sin(tpt*cf);
coscf=zeros(npts,1);
sincf=coscf;
cold=1;
sold=0;
coscf(1)=cold;
sincf(1)=sold;
for n=2:npts
    arg=cold*cn + sold*sn;
    sold=sold*cn - cold*sn;
    cold=arg;
    coscf(n)=cold;
    sincf(n)=sold;
end

% Filter the real and imaginary parts of the signal
ureal=filter([1 a1 a5],[1 -a1 -a2 -a3 -a4],x.*coscf);
uimag=filter([1 a1 a5],[1 -a1 -a2 -a3 -a4],x.*sincf);

% Extract the BM velocity and the envelope
envx=gain*sqrt(ureal.*ureal + uimag.*uimag);

% ---------------------------------------
% Filter the second signal using the existing cosine and sine sequences
% Initialize the filter coefficients
tptBW=BWy*tpt*ERB*1.019;
a=exp(-tptBW);
a1=4.0*a;
a2=-6.0*a*a;
a3=4.0*a*a*a;
a4=-a*a*a*a;
a5=4.0*a*a;
gain=2.0*(1-a1-a2-a3-a4)/(1+a1+a5);

% Filter the real and imaginary parts of the signal
ureal=filter([1 a1 a5],[1 -a1 -a2 -a3 -a4],y.*coscf);
uimag=filter([1 a1 a5],[1 -a1 -a2 -a3 -a4],y.*sincf);

% Extract the BM velocity and the envelope
envy=gain*sqrt(ureal.*ureal + uimag.*uimag);
