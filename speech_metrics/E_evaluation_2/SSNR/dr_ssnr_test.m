clear;
indir='C:\Users\yunfan\Desktop\evaluation\DAE_VAD'; % ��J enhancement data ��Ƨ�
in_filter='\.wav'; % ���ɦW
in1dir='C:\Users\yunfan\Desktop\evaluation\noisy\pink\0db'; % ��J noisy data ��Ƨ�
in1_filter='\.wav';      % ���ɦW                                                       
speech='C:\Users\yunfan\Desktop\evaluation\clean';    % clean data 
speech_filter='\.wav';      % ���ɦW
len=160; % frame length
dr_ssnr(indir,in_filter,in1dir,in1_filter,speech,speech_filter,len)
