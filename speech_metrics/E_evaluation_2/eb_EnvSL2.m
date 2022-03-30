function [y,b]=eb_EnvSL2(env,bm,attnIHC,Level1)
% Function to convert the compressed envelope returned by
% cochlea_envcomp to dB SL.
%
% Calling arguments
% env			linear envelope after compression
% bm            linear basilar membrane vibration after compression
% attnIHC		IHC attenuation at the input to the synapse
% Level1		level in dB SPL corresponding to 1 RMS
%
% Return
% y				envelope in dB SL
% b             BM vibration with envelope converted to dB SL
%
% James M. Kates, 20 Feb 07.
% IHC attenuation added 9 March 2007.
% Basilar membrane vibration conversion added 2 October 2012.

% Convert the envelope to dB SL
small=1.0e-30; %To prevent taking log of 0
y=Level1 - attnIHC + 20*log10(env + small);
y=max(y,0.0);

% Convert the linear BM motion to have a dB SL envelope
gain=(y + small)./(env + small); %Gain that converted the env from lin to dB SPL
b=gain.*bm; %Apply gain to BM motion
end
