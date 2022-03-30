function smooth=eb_EnvSmooth(env,segsize,fsamp)
% Function to smooth the envelope returned by the cochlear model. The
% envelope is divided into segments having a 50% overlap. Each segment is
% windowed, summed, and divided by the window sum to produce the average.
% A raised cosine window is used. The envelope sub-sampling frequency is
% 2*(1000/segsize).
%
% Calling arguments:
% env			matrix of envelopes in each of the auditory bands
% segsize		averaging segment size in msec
% fsamp			input envelope sampling rate in Hz
%
% Returned values:
% smooth		matrix of subsampled windowed averages in each band
%
% James M. Kates, 26 January, 2007.
% Final half segment added 27 August 2012.

% Compute the window
nwin=round(segsize*(0.001*fsamp)); %Segment size in samples
test=nwin - 2*floor(nwin/2); %0=even, 1=odd
if test>0; nwin=nwin+1; end; %Force window length to be even
window=hann(nwin); %Raised cosine von Hann window
wsum=sum(window); %Sum for normalization

% The first segment has a half window
nhalf=nwin/2;
halfwindow=window(nhalf+1:nwin);
halfsum=sum(halfwindow);

% Number of segments and assign the matrix storage
nchan=size(env,1);
npts=size(env,2);
nseg=1 + floor(npts/nwin) + floor((npts-nwin/2)/nwin);
smooth=zeros(nchan,nseg);

% Loop to compute the envelope in each frequency band
for k=1:nchan
%	Extract the envelope in the frequency band
	r=env(k,:);

%	The first (half) windowed segment
	nstart=1;
	smooth(k,1)=sum(r(nstart:nhalf).*halfwindow')/halfsum;

%	Loop over the remaining full segments, 50% overlap
	for n=2:nseg-1
		nstart=nstart + nhalf;
		nstop=nstart + nwin - 1;
		smooth(k,n)=sum(r(nstart:nstop).*window')/wsum;
    end
    
%   The last (half) windowed segment
 	nstart=nstart + nhalf;
	nstop=nstart + nhalf - 1;
    smooth(k,nseg)=sum(r(nstart:nstop).*window(1:nhalf)')/halfsum;    
end
