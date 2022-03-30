function title_flag=EVALUATION_MAIN_V1(indir1,indir2,indir3,outdir,outfilename,title_flag)

% indir1: document path for clean data
% indir2: document path for noisy data
% indir3: document path for enhanced data
% outdir: document path for evaluated results

if nargin == 5
    title_flag=1;
end

if  indir1(end) == filesep
    indir1=indir1(1:(end-1));
end
if  indir2(end) == filesep
    indir2=indir2(1:(end-1));
end
if  indir3(end) == filesep
    indir3=indir3(1:(end-1));
end

if  strcmp(outdir(end),'\') || strcmp(outdir(end),'/')
    outdir=outdir(1:(end-1));
end

if exist(outdir) ~=7
    mkdir(outdir);
end

filelist_1=dir(indir1);
filelist_2=dir(indir2);
filelist_3=dir(indir3);
filelist_len=length(filelist_1);

for k=3:filelist_len
    [pathstr_1,filenamek_1,ext_1] = fileparts(filelist_1(k).name);
    [pathstr_2,filenamek_2,ext_1] = fileparts(filelist_2(k).name);
    [pathstr_3,filenamek_3,ext_1] = fileparts(filelist_3(k).name);
    if filelist_1(k).isdir
        title_flag=EVALUATION_MAIN_V1([indir1 filesep filenamek_1],[indir2 filesep filenamek_2],[indir3 filesep filenamek_3],outdir,title_flag);
    else
        
        CleanDataFile=fullfile(indir1, filelist_1(k).name);
        NoisyDataFile=fullfile(indir2, filelist_1(k).name);
        EnhadDataFile=fullfile(indir3, filelist_1(k).name);
        
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
        len=256; % frame length
        
        
        % SDI test
        sdi(k-2)=compute_sdi(CleanData,EnhadData);
        % SSNR
        if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
            ssnr_dB(k-2)=ssnr(EnhadData,NoisyData,CleanData,len);
%             ssnr_dB(k-2)=0;
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
            fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\t%f\n',filelist_1(k).name,pesq_mos(k-2),HASQI(k-2),HASPI(k-2),sdi(k-2),0);
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
        fprintf(fw,'%20s:\t%f\t%f\t%f\t%f\t%f\n','Stad',std_pesq,std_hasqi,std_haspi,std_sdi,-1);
    end
    fclose(fw);
end
end