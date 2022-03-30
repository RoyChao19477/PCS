function [ydB,yBM] = eb_IHCadapt(xdB,xBM,delta,fsamp)
% Function to provide inner hair cell (IHC) adaptation. The adaptation is
% based on an equivalent RC circuit model, and the derivatives are mapped
% into 1st-order backward differences. Rapid and short-term adaptation are
% provided. The input is the signal envelope in dB SL, with IHC attenuation
% already applied to the envelope. The outputs are the envelope in dB SL
% with adaptation providing overshoot of the long-term output level, and
% the BM motion is multiplied by a gain vs. time function that reproduces
% the adaptation. IHC attenuation and additive noise for the equivalent
% auditory threshold are provided by a subsequent call to eb_BMatten.
%
% Calling variables:
% xdB      signal envelope in one frequency band in dB SL
%          contains OHC compression and IHC attenuation
% xBM      basilar membrane vibration with OHC compression but no IHC atten
% delta    overshoot factor = delta x steady-state
% fsamp    sampling rate in Hz
%
% Returned values:
% ydB      envelope in dB SL with IHC adaptation
% yBM      BM motion multiplied by the IHC adaptation gain function
%
% James M. Kates, 1 October 2012.

% Test the amount of overshoot
dsmall=1.0001;
if delta < dsmall
    delta=dsmall;
end

% Initialize the adaptation time constants
tau1=2; %Rapid adaptation in msec
tau2=60; %Short-term adaptation in msec
tau1=0.001*tau1; tau2=0.001*tau2; %Convert to seconds

% Equivalent circuit parameters
T=1/fsamp; %Sampling period
R1=1/delta;
R2=0.5*(1 - R1);
R3=R2;
C1=tau1*(R1 + R2)/(R1*R2);
C2=tau2/((R1 + R2)*R3);

% Intermediate values used for the voltage update matrix inversion
a11=R1 + R2 + R1*R2*(C1/T);
a12=-R1;
a21=-R3;
a22=R2 + R3 + R2*R3*(C2/T);
denom=1.0/(a11*a22 - a21*a12);

% Additional intermediate values
R1inv=1.0/R1;
R12C1=R1*R2*(C1/T);
R23C2=R2*R3*(C2/T);

% Initialize the outputs and state of the equivalent circuit
nsamp=length(xdB);
gain=ones(size(xdB)); %Gain vector to apply to the BM motion, default is 1
ydB=zeros(size(xdB)); %Assign storage
V1=0.0;
V2=0.0;
small=1.0e-30;

% Loop to process the envelope signal
% The gain asymptote is 1 for an input envelope of 0 dB SL
for n=1:nsamp
    V0=xdB(n);
    b1=V0*R2 + R12C1*V1;
    b2=R23C2*V2;
    V1=denom*(a22*b1 - a12*b2);
    V2=denom*(-a21*b1 + a11*b2);
    out=(V0 - V1)*R1inv;
    out=max(out,0.0); %Envelope can not drop below threshold
    ydB(n)=out; %Envelope with IHC adaptation
    gain(n)=(out + small)/(V0 + small); %Avoid division by zero
end

% Apply the gain to the BM vibration
yBM=gain.*xBM;
end

