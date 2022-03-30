function title_flag=EVALUATION_MAIN_V2(InputDirStructure,OutputDirStructure,title_flag)

% CLDatapath            : document path for clean data
% NYDatapath           : document path for noisy data
% EnhanCLDatapath : document path for enhanced clean data
% NEDatapath            : document path for enhanced noisy data
% EnhanNEdatapath : document path for noise data
% outdir                       : document path for evaluated results
% outfilename             : file name for evaluated results

InputNameField={'CLDatapath','NYDatapath','NEDatapath','EnhanCLDatapath','EnhanNEdatapath'};

if nargin == 2
    title_flag=1;
end

if isfield(InputDirStructure,'CLDatapath'); InpDir.CLDatapath=InputDirStructure.CLDatapath;end;% Seperation & Enhancement
if isfield(InputDirStructure,'NEDatapath'); InpDir.NEDatapath=InputDirStructure.NEDatapath;end;% Seperation
if isfield(InputDirStructure,'NYDatapath'); InpDir.NYDatapath=InputDirStructure.NYDatapath;end;% Seperation & Enhancement
if isfield(InputDirStructure,'EnhanCLDatapath'); InpDir.EnhanCLDatapath=InputDirStructure.EnhanCLDatapath;end;% Seperation & Enhancement
if isfield(InputDirStructure,'EnhanNEdatapath'); InpDir.EnhanNEdatapath=InputDirStructure.EnhanNEdatapath;end;% Seperation

if isfield(InpDir,'CLDatapath') && isfield(InpDir,'NYDatapath') && isfield(InpDir,'EnhanCLDatapath')
    
    outdir          =OutputDirStructure.Outputpath;
    outfilename=OutputDirStructure.OutputFileName;
    
    if  strcmp(outdir(end),'\') || strcmp(outdir(end),'/')
        outdir=outdir(1:(end-1));
    end
    if exist(outdir) ~=7
        mkdir(outdir);
    end
    
    
    strfieldnum=length(struct2cell(InpDir));
    switch strfieldnum
        case 3
            title_flag=sub_evaluation_three_input(InpDir,outdir,outfilename,title_flag);
        case 5
            title_flag=sub_evaluation_five_input(InpDir,outdir,outfilename,title_flag);
    end
    
else
    disp('Error: Not supplied input format')
end
end

function title_flag=sub_evaluation_three_input(InpDir,outdir,outfilename,title_flag)

if  InpDir.CLDatapath(end) == filesep
    InpDir.CLDatapath=InpDir.CLDatapath(1:(end-1));
end
if  InpDir.NYDatapath(end) == filesep
    InpDir.NYDatapath=InpDir.NYDatapath(1:(end-1));
end
if  InpDir.EnhanCLDatapath(end) == filesep
    InpDir.EnhanCLDatapath=InpDir.EnhanCLDatapath(1:(end-1));
end

filelist_1=dir(InpDir.CLDatapath);
filelist_2=dir(InpDir.NYDatapath);
filelist_3=dir(InpDir.EnhanCLDatapath);
filelist_len=length(filelist_1);

for k=3:filelist_len
    [pathstr_1,filenamek_1,ext_1] = fileparts(filelist_1(k).name);
    [pathstr_2,filenamek_2,ext_1] = fileparts(filelist_2(k).name);
    [pathstr_3,filenamek_3,ext_1] = fileparts(filelist_3(k).name);
    if filelist_1(k).isdir
        InputDirStructure.CLDatapath=[InpDir.CLDatapath filesep filenamek_1];
        InputDirStructure.NYDatapath=[InpDir.NYDatapath filesep filenamek_2];
        InputDirStructure.EnhanCLDatapath=[InpDir.EnhanCLDatapath filesep filenamek_3];
        title_flag=sub_evaluation_three_input(InputDirStructure,outdir,outfilename,title_flag);
    else
        
        CleanDataFile=fullfile(InpDir.CLDatapath, filelist_1(k).name);
        NoisyDataFile=fullfile(InpDir.NYDatapath, filelist_2(k).name);
        EnhadDataFile=fullfile(InpDir.EnhanCLDatapath, filelist_3(k).name);
        
        [CleanData,fc]=wavread(CleanDataFile);
        [NoisyData,fn]=wavread(NoisyDataFile);
        [EnhadData,fe]=wavread(EnhadDataFile);
        
        CleanData1=sqrt(mean2(CleanData.^2));
        NoisyData1=sqrt(mean2(NoisyData.^2));
        EnhadData1=sqrt(mean2(EnhadData.^2));
        
        CleanData = CleanData/CleanData1;
        NoisyData = NoisyData/NoisyData1;
        EnhadData = EnhadData/EnhadData1;
        
        % for HASQI used!
        HL = [0, 0, 0, 0, 0, 0];
        eq = 2;
        Level1 = 65;
        % for SSNR
        len=160; % frame length
        
        
        % SDI test
        sdi(k-2)=compute_sdi(CleanData,EnhadData);
        % SSNR
        if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
            ssnr_dB(k-2)=ssnr(EnhadData,NoisyData,CleanData,len);
        end
        %HASQI
        [Combined,Nonlin,Linear,raw]=HASQI_v2(CleanData,fc,EnhadData,fe,HL,eq,Level1);
        HASQI(k-2)=Combined;
        %HASPI
        [Intel,raw] = HASPI_v1(CleanData,fc,EnhadData,fe,HL,Level1);
        HASPI(k-2)=Intel;
        %PESQ
        pesq_mos(k-2)=pesq(CleanData, EnhadData);
        
        
        %Writing process
        if title_flag == 1
            fw=fopen(sprintf('%s%s%s.txt',outdir,filesep,outfilename),'wb');
            if fw ~= -1
                fprintf(fw,'%20s:\t%7s\t%8s\t%8s\t%8s\t%9s\n','EVALUATED METHODS','PESQ','HASQI','HASPI','SDI','SSNR');
                title_flag=0;
            else
                disp('Error: Cannot open the text file. Stop.');
                break;
            end
        end
        
        %'PESQ','HASQI','HASPI','SDI','SSNR'
        if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
            fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\t%f\n',filelist_1(k).name,pesq_mos(k-2),HASQI(k-2),HASPI(k-2),sdi(k-2),ssnr_dB(k-2));
        else
            fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\t%f\n',filelist_1(k).name,pesq_mos(k-2),HASQI(k-2),HASPI(k-2),0,0);
        end
        
    end
end

if ~isempty(sdi)
    
    % mean and variance calcualtion
    mean_sdi=mean(sdi);
    std_sdi=std(sdi);
    if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
        mean_ssnr=mean(ssnr_dB);
        std_ssnr=std(ssnr_dB);
    end
    mean_hasqi=mean(HASQI);
    std_hasqi=std(HASQI);
    mean_haspi=mean(HASPI);
    std_haspi=std(HASPI);
    mean_pesq=mean(pesq_mos);
    std_pesq=std(pesq_mos);
    
    %Writing process
    %'PESQ','HASQI','HASPI','SDI','SSNR'
    if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\t%f\n','Mean',mean_pesq,mean_hasqi,mean_haspi,mean_sdi,mean_ssnr);
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\t%f\n','Stad',std_pesq,std_hasqi,std_haspi,std_sdi,std_ssnr);
    else
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\t%f\n','Mean',mean_pesq,mean_hasqi,mean_haspi,mean_sdi,0);
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\t%f','Stad',std_pesq,std_hasqi,std_haspi,std_sdi,-1);
    end
    fclose(fw);
end

end

function title_flag=sub_evaluation_five_input(InpDir,outdir,outfilename,title_flag)

if  InpDir.CLDatapath(end) == filesep
    InpDir.CLDatapath=InpDir.CLDatapath(1:(end-1));
end
if  InpDir.NYDatapath(end) == filesep
    InpDir.NYDatapath=InpDir.NYDatapath(1:(end-1));
end
if  InpDir.NEDatapath(end) == filesep
    InpDir.NEDatapath=InpDir.NEDatapath(1:(end-1));
end
if  InpDir.EnhanCLDatapath(end) == filesep
    InpDir.EnhanCLDatapath=InpDir.EnhanCLDatapath(1:(end-1));
end
if  InpDir.EnhanNEdatapath(end) == filesep
    InpDir.EnhanNEdatapath=InpDir.EnhanNEdatapath(1:(end-1));
end

filelist_1=dir(InpDir.CLDatapath);
filelist_2=dir(InpDir.NYDatapath);
filelist_3=dir(InpDir.EnhanCLDatapath);
filelist_4=dir(InpDir.NEDatapath);
filelist_5=dir(InpDir.EnhanNEdatapath);
filelist_len=length(filelist_1);

for k=3:filelist_len
    [pathstr_1,filenamek_1,ext_1] = fileparts(filelist_1(k).name);
    [pathstr_2,filenamek_2,ext_1] = fileparts(filelist_2(k).name);
    [pathstr_3,filenamek_3,ext_1] = fileparts(filelist_3(k).name);
    [pathstr_4,filenamek_4,ext_1] = fileparts(filelist_4(k).name);
    [pathstr_5,filenamek_5,ext_1] = fileparts(filelist_5(k).name);
    if filelist_1(k).isdir
        InputDirStructure.CLDatapath=[InpDir.CLDatapath filesep filenamek_1];
        InputDirStructure.NYDatapath=[InpDir.NYDatapath filesep filenamek_2];
        InputDirStructure.EnhanCLDatapath=[InpDir.EnhanCLDatapath filesep filenamek_3];
        InputDirStructure.NEDatapath=[InpDir.NEDatapath filesep filenamek_4];
        InputDirStructure.EnhanNEdatapath=[InpDir.EnhanNEdatapath filesep filenamek_5];
        
        title_flag=sub_evaluation_five_input(InputDirStructure,outdir,outfilename,title_flag);
    else
        
        CleanDataFile=fullfile(InpDir.CLDatapath, filelist_1(k).name);
        NoisyDataFile=fullfile(InpDir.NYDatapath, filelist_2(k).name);
        EnhadCLDataFile=fullfile(InpDir.EnhanCLDatapath, filelist_3(k).name);
        NoiseDataFile=fullfile(InpDir.NEDatapath, filelist_4(k).name);
        EnhadNEDataFile=fullfile(InpDir.EnhanNEdatapath, filelist_5(k).name);
        
        [CleanData,fc]=wavread(CleanDataFile);
        [NoisyData,fn]=wavread(NoisyDataFile);
        [NoiseData,fe]=wavread(NoiseDataFile);
        [EnhadCLData,fec]=wavread(EnhadCLDataFile);
        [EnhadNEData,fen]=wavread(EnhadNEDataFile);
        %         [EnhadCLData,fec]=wavread(sprintf('C:/Users/sypdbhee/Documents/MATLAB/sypdbhee/L_from_Lab/code_org/Data/Test/DAE_SEPERATED/MHINT%s%s.wav',filesep,int2str(k-2)));
        %         [EnhadNEData,fen]=wavread(sprintf('C:/Users/sypdbhee/Documents/MATLAB/sypdbhee/L_from_Lab/code_org/Data/Test/DAE_SEPERATED/NOISE%s%s.wav',filesep,int2str(k-2)));
        CleanData1=sqrt(mean2(CleanData.^2));
        NoisyData1=sqrt(mean2(NoisyData.^2));
        NoiseData1=sqrt(mean2(NoiseData.^2));
        EnhadCLData1=sqrt(mean2(EnhadCLData.^2));
        EnhadNEData1=sqrt(mean2(EnhadNEData.^2));
        
        
        CleanData = CleanData/CleanData1;
        NoisyData = NoisyData/NoisyData1;
        NoiseData = NoiseData/NoiseData1;
        EnhadCLData = EnhadCLData/EnhadCLData1;
        EnhadNEData = EnhadNEData/EnhadNEData1;
        
        
        
        % for HASQI used!
        HL = [0, 0, 0, 0, 0, 0];
        eq = 2;
        Level1 = 65;
        % for SSNR
        len=160; % frame length
        
        
        
        % SDI test
        sdi_encl_cl(k-2)=compute_sdi(CleanData,EnhadCLData);
        sdi_enne_ne(k-2)=compute_sdi(NoiseData,EnhadNEData);
        sdi_cl_ny(k-2)=compute_sdi(CleanData,NoisyData);
        sdi_ne_ny(k-2)=compute_sdi(NoiseData,NoisyData);
        % SSNR
        ssnr_dB_encl_cl(k-2)=ssnr(EnhadCLData,NoisyData,CleanData,len);
        ssnr_dB_enne_ne(k-2)=ssnr(EnhadNEData,NoisyData,NoiseData,len);
        %HASQI
        [HASQI_encl_cl(k-2),Nonlin,Linear,raw]=HASQI_v2(CleanData,fc,EnhadCLData,fec,HL,eq,Level1);
        [HASQI_enne_ne(k-2),Nonlin,Linear,raw]=HASQI_v2(NoiseData,fn,EnhadNEData,fen,HL,eq,Level1);
        [HASQI_cl_ny(k-2),Nonlin,Linear,raw]=HASQI_v2(CleanData,fc,NoisyData,fec,HL,eq,Level1);
        [HASQI_ne_ny(k-2),Nonlin,Linear,raw]=HASQI_v2(NoiseData,fn,NoisyData,fen,HL,eq,Level1);
        %HASPI
        [HASPI_encl_cl(k-2),raw] = HASPI_v1(CleanData,fc,EnhadCLData,fec,HL,Level1);
        [HASPI_enne_ne(k-2),raw] = HASPI_v1(NoiseData,fn,EnhadNEData,fen,HL,Level1);
        [HASPI_cl_ny(k-2),raw] = HASPI_v1(CleanData,fc,NoisyData,fec,HL,Level1);
        [HASPI_ne_ny(k-2),raw] = HASPI_v1(NoiseData,fn,NoisyData,fen,HL,Level1);
        %PESQ
        pesq_mos_encl_cl(k-2)=pesq(CleanData, EnhadCLData);
        pesq_mos_enne_ne(k-2)=pesq(CleanData, EnhadNEData);
        pesq_mos_cl_ny(k-2)=pesq(CleanData, NoisyData);
        pesq_mos_ne_ny(k-2)=pesq(CleanData, NoisyData);
        
        %SDR SIR SAR
        if length(CleanData)>length(EnhadCLData)
            [SDR(k-2),SIR(k-2),SAR(k-2),perm] = bss_eval_sources( [EnhadCLData; EnhadNEData]', [CleanData(1:length(EnhadCLData)); NoiseData(1:length(EnhadNEData))]');
        else
            [SDR(k-2),SIR(k-2),SAR(k-2),perm] = bss_eval_sources( [EnhadCLData(1:length(CleanData)); EnhadNEData(1:length(NoiseData))]', [CleanData; NoiseData]');
        end
        
        
        %Writing process
        if title_flag == 1
            fw=fopen(sprintf('%s%s%s.txt',outdir,filesep,outfilename),'wb');
            if fw ~= -1
                fprintf(fw,'%20s:\t%13s\t%13s\t%13s\t%13s\t%13s\t\t\t\t%13s\t%13s\t%13s\t%13s\t%13s\t\t\t\t%13s\t%13s\t%13s\t\t\t\t%13s\t%13s\t%13s\t%13s\t\t\t\t%13s\t%13s\t%13s\t%13s\n',...
                    'EVALUATED METHODS',...
                    'PESQ_ENCL_CL','HASQI_ENCL_CL','HASPI_ENCL_CL','SDI_ENCL_CL','SSNR_ENCL_CL'...
                    ,'PESQ_ENNO_NY','HASQI_ENNO_NY','HASPI_ENNO_NY','SDI_ENNO_NY','SSNR_ENNO_NY'...
                    ,'SDR','SIR','SAR'...
                    ,'PESQ_CL_NY','HASQI_CL_NY','HASPI_CL_NY','SDI_CL_NY'...
                    ,'PESQ_NE_NY','HASQI_NE_NY','HASPI_NE_NY','SDI_NE_NY'...
                    );
                title_flag=0;
            else
                disp('Error: Cannot open the text file. Stop.');
                break;
            end
        end
        
        %'PESQ_ENCL' 'PESQ_ENNO' 'HASQI_ENCL' 'HASQI_ENNO' 'HASPI_ENCL' 'HASPI_ENNO' 'SDI_ENCL' 'SDI_ENNO' 'SSNR_ENCL' 'SSNR_ENNO' 'SDR' 'SIR' 'SAR'
        fprintf(fw,'%20s:\t%13f\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\n',...
            filelist_1(k).name,...
            pesq_mos_encl_cl(k-2),HASQI_encl_cl(k-2),HASPI_encl_cl(k-2),sdi_encl_cl(k-2),ssnr_dB_encl_cl(k-2)...
            ,pesq_mos_enne_ne(k-2),HASQI_enne_ne(k-2),HASPI_enne_ne(k-2),sdi_enne_ne(k-2),ssnr_dB_enne_ne(k-2)...
            ,SDR(k-2),SIR(k-2),SAR(k-2)...
            ,pesq_mos_cl_ny(k-2),HASQI_cl_ny(k-2),HASPI_cl_ny(k-2),sdi_cl_ny(k-2)...
            ,pesq_mos_ne_ny(k-2),HASQI_ne_ny(k-2),HASPI_ne_ny(k-2),sdi_ne_ny(k-2)...
            );
        
    end
end

if ~isempty(sdi_encl_cl)
    
    % mean and variance calcualtion
    mean_sdienclcl=mean(sdi_encl_cl);std_sdienclcl=std(sdi_encl_cl);
    mean_sdiennene=mean(sdi_enne_ne);std_sdiennene=std(sdi_enne_ne);
    mean_ssnrenclcl=mean(ssnr_dB_encl_cl);std_ssnrenclcl=std(ssnr_dB_encl_cl);
    mean_ssnrennene=mean(ssnr_dB_enne_ne);std_ssnrennene=std(ssnr_dB_enne_ne);
    mean_hasqienclcl=mean(HASQI_encl_cl);std_hasqienclcl=std(HASQI_encl_cl);
    mean_hasqiennene=mean(HASQI_enne_ne);std_hasqiennene=std(HASQI_enne_ne);
    mean_haspienclcl=mean(HASPI_encl_cl);std_haspienclcl=std(HASPI_encl_cl);
    mean_haspiennene=mean(HASPI_enne_ne);std_haspiennene=std(HASPI_enne_ne);
    mean_pesqenclcl=mean(pesq_mos_encl_cl);std_pesqenclcl=std(pesq_mos_encl_cl);
    mean_pesqennene=mean(pesq_mos_enne_ne);std_pesqennene=std(pesq_mos_enne_ne);
    
    mean_pesqclny=mean(pesq_mos_cl_ny);std_pesqclny=std(pesq_mos_cl_ny);
    mean_haspiclny=mean(HASPI_cl_ny);std_haspiclny=std(HASPI_cl_ny);
    mean_sdiclny=mean(sdi_cl_ny);std_sdiclny=std(sdi_cl_ny);
    mean_hasqiclny=mean(HASQI_cl_ny);std_hasqiclny=std(HASQI_cl_ny);
    
    mean_pesqneny=mean(pesq_mos_ne_ny);std_pesqneny=std(pesq_mos_ne_ny);
    mean_haspineny=mean(HASPI_ne_ny);std_haspineny=std(HASPI_ne_ny);
    mean_sdineny=mean(sdi_ne_ny);std_sdineny=std(sdi_ne_ny);
    mean_hasqineny=mean(HASQI_ne_ny);std_hasqineny=std(HASQI_ne_ny);
    
    mean_sdr=mean(SDR);std_sdr=std(SDR);
    mean_sir=mean(SIR);std_sir=std(SIR);
    mean_sar=mean(SAR);std_sar=std(SAR);
    
    %Writing process
    %'PESQ_ENCL' 'PESQ_ENNO' 'HASQI_ENCL' 'HASQI_ENNO' 'HASPI_ENCL' 'HASPI_ENNO' 'SDI_ENCL' 'SDI_ENNO' 'SSNR_ENCL' 'SSNR_ENNO' 'SDR' 'SIR' 'SAR'
    fprintf(fw,'%20s:\t%13f\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\n','Mean'...
        ,mean_pesqenclcl,mean_hasqienclcl,mean_haspienclcl,mean_sdienclcl,mean_ssnrenclcl...
        ,mean_pesqennene,mean_hasqiennene,mean_haspiennene,mean_sdiennene,mean_ssnrennene...
        ,mean_sdr,mean_sir,mean_sar...
        ,mean_pesqclny,mean_hasqiclny,mean_haspiclny,mean_sdiclny...
        ,mean_pesqneny,mean_hasqineny,mean_haspineny,mean_sdineny...
        );
    fprintf(fw,'%20s:\t%13f\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\t\t\t\t%13f\t%13f\t%13f\t%13f\n','Stad'...
        ,std_pesqenclcl,std_hasqienclcl,std_haspienclcl,std_sdienclcl,std_ssnrenclcl...
        ,std_pesqennene,std_hasqiennene,std_haspiennene,std_sdiennene,std_ssnrennene...
        ,std_sdr,std_sir,std_sar...
        ,std_pesqclny,std_hasqiclny,std_haspiclny,std_sdiclny...
        ,std_pesqneny,std_hasqineny,std_haspineny,std_sdineny...
        );
    fclose(fw);
end

end
