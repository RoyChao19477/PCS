clear;
indir='.\output\WF+4chDPF(ER=5)'; % ��J enhancement data ��Ƨ�
in_filter='\.wav';    % ���ɦW                   
cleanFile='.\input';      % clean data       
clean_filter='\.wav';
% ***************************************
% for HASQI used!
HL = [0, 0, 0, 0, 0, 0];
eq = 2;
Level1 = 65;
% *************************************
dr_pesq(indir,in_filter,cleanFile,clean_filter);
dr_HASQI(indir,in_filter,cleanFile,clean_filter,HL,eq,Level1);
dr_HASPI(indir,in_filter,cleanFile,clean_filter,HL,Level1);