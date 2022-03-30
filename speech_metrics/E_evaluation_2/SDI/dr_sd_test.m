clear;
indir='C:\Users\yunfan\Desktop\evaluation\noisy\pink\0db'; % 輸入 enhancement data 資料夾
in_filter='\.wav';    % 副檔名                       
cleanFile='C:\Users\yunfan\Desktop\evaluation\clean';      % clean data       
clean_filter='\.wav';
dr_sd(indir,in_filter,cleanFile,clean_filter)