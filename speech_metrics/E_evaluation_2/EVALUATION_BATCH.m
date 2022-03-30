
filepath='C:\Users\sypdbhee\Documents\MATLAB\sypdbhee\L_from_Lab\code_org\Data\Test\evaluation\';
CleanPath='C:\Users\sypdbhee\Documents\MATLAB\sypdbhee\L_from_Lab\code_org\Data\Test\evaluation\clean';
NoisyPath='C:\Users\sypdbhee\Documents\MATLAB\sypdbhee\L_from_Lab\code_org\Data\Test\evaluation\noisy\pink\0db';

EvalOut='C:\Users\sypdbhee\Documents\MATLAB\sypdbhee\L_from_Lab\code_org\Data\Test\performanceout';

% % FileName={'pink_0dB_ws_0_importantfunc';'pink_0dB_ws_0_tr_clknnforny_ts_clknnforny_withlabelout';'pink_0dB_ws_0_tr_nyvadforny_ts_nyvad_withlabelout';'pink_0dB_ws_0_tr_clvadforny_ts_clvad_withlabelout';'pink_0dB_ws_0_with_tr_nyknnforny_ts_nyknnforny_withlabelout'};
% FileName={'DAE'};

%%
% EVALUATION_MAIN(CleanPath,NoisyPath,NoisyPath,EvalOut,'Noisy');

%%
% for file_ind=1:length(FileName)
%     EVALUATION_MAIN_V1(CleanPath,NoisyPath,sprintf('%s%s',filepath,FileName{file_ind}),EvalOut,FileName{file_ind});
% end

%%

% InputDirStructure.CLDatapath=CleanPath;
% InputDirStructure.NYDatapath=NoisyPath;
% InputDirStructure.EnhanCLDatapath=sprintf('%s%s',filepath,FileName{file_ind});
% 
% OutputDirStructure.Outputpath=EvalOut;
% OutputDirStructure.OutputFileName=FileName{1};
% 
% EVALUATION_MAIN_V2(InputDirStructure,OutputDirStructure);

%%

% if isfield(InputDirStructure,'CLDatapath'); InpDir.CLDatapath=InputDirStructure.CLDatapath;end;% Seperation & Enhancement
% if isfield(InputDirStructure,'NEDatapath'); InpDir.NEDatapath=InputDirStructure.NEDatapath;end;% Seperation
% if isfield(InputDirStructure,'NYDatapath'); InpDir.NYDatapath=InputDirStructure.NYDatapath;end;% Seperation & Enhancement
% if isfield(InputDirStructure,'EnhanCLDatapath'); InpDir.EnhanCLDatapath=InputDirStructure.EnhanCLDatapath;end;% Seperation & Enhancement
% if isfield(InputDirStructure,'EnhanNEdatapath'); InpDir.EnhanNEdatapath=InputDirStructure.EnhanNEdatapath;end;% Seperation

EvalPath='C:\Users\sypdbhee\Documents\MATLAB\sypdbhee\L_from_Lab\code_org\Data\16k\eval\';
NoisyFolder='noisy';
CleanFolder='clean';
NoiseFolder='noise';

FileName={'Enhancement_two_branch_segmental'};InputDirStructure=[];

InputDirStructure.CLDatapath=sprintf('%s%s',EvalPath,CleanFolder);
InputDirStructure.NYDatapath=sprintf('%s%s',EvalPath,NoisyFolder);
InputDirStructure.EnhanCLDatapath='C:\Users\sypdbhee\Documents\MATLAB\sypdbhee\L_from_Lab\code_org\Data\Test\DAE_SEPERATED\Segmental\MHINT';
% InputDirStructure.NEDatapath=sprintf('%s%s',EvalPath,NoiseFolder);
% InputDirStructure.EnhanNEdatapath='C:\Users\sypdbhee\Documents\MATLAB\sypdbhee\L_from_Lab\code_org\Data\Test\DAE_SEPERATED\NOISE';

OutputDirStructure.Outputpath=EvalOut;
OutputDirStructure.OutputFileName=FileName{1};

EVALUATION_MAIN_V2(InputDirStructure,OutputDirStructure);








