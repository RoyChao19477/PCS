clear;
indir='C:\Users\yunfan\Desktop\evaluation\DAE_VAD'; % 輸入 enhancement data 資料夾
in_filter='\.wav'; % 副檔名
in1dir='C:\Users\yunfan\Desktop\evaluation\noisy\pink\0db'; % 輸入 noisy data 資料夾
in1_filter='\.wav';      % 副檔名                                                       
speech='C:\Users\yunfan\Desktop\evaluation\clean';    % clean data 
speech_filter='\.wav';      % 副檔名
len=160; % frame length
dr_ssnr(indir,in_filter,in1dir,in1_filter,speech,speech_filter,len)
