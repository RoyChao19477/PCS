function EVALUATION_MAIN_V3_SSNRSTOI(indir1,indir2,indir3,outdir,outfilename)

% indir1: document path for clean data
% indir2: document path for noisy data
% indir3: document path for enhanced data
% outdir: document path for evaluated results

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

title_flag=1;

for k=3:filelist_len
    [pathstr_1,filenamek_1,ext_1] = fileparts(filelist_1(k).name);
    [pathstr_2,filenamek_2,ext_1] = fileparts(filelist_2(k).name);
    [pathstr_3,filenamek_3,ext_1] = fileparts(filelist_3(k).name);
    if filelist_1(k).isdir
        EVALUATION_MAIN_V3_SSNRSTOI([indir1 filesep filenamek_1],[indir2 filesep filenamek_2],[indir3 filesep filenamek_3],outdir)
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
        
        % for SSNR
        len=256; % frame length        
        
        if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
            ssnr_dB(k-2)=ssnr(EnhadData,NoisyData,CleanData,len);
        end
        
        %STOI
        stoi_scor(k-2) = stoi(CleanData, EnhadData, fc);
        
        
        %Writing process
        if title_flag == 1
            fw=fopen(sprintf('%s%s%s.txt',outdir,filesep,outfilename),'wb');
            if fw ~= -1
                fprintf(fw,'%20s:\t%8s\t%9s\n','EVALUATED METHODS','STOI','SSNR');
                title_flag=0;
            else
                disp('Error: Cannot open the text file. Stop.');
                break;
            end
        end
        
        %'STOI','SSNR'
        if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
            fprintf(fw,'%20s:\t%f\t%f\n',filelist_1(k).name,stoi_scor(k-2),ssnr_dB(k-2));
        else
            fprintf(fw,'%20s:\t%f\t%f\n',filelist_1(k).name,stoi_scor(k-2),0);
        end
        
    end
end

if ~isempty(stoi_scor)
    
    % mean and variance calcualtion
    mean_stoi=mean(stoi_scor);
    std_stoi=std(stoi_scor);
    if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
        mean_ssnr=mean(ssnr_dB);
        std_ssnr=std(ssnr_dB);
    end
    
    %Writing process
    %'PESQ','HASQI','HASPI','SDI','SSNR'
    if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
        fprintf(fw,'%20s:\t%f\t%f\n','Mean',mean_stoi,mean_ssnr);
        fprintf(fw,'%20s:\t%f\t%f\n','Stad',std_stoi,std_ssnr);
    else
        fprintf(fw,'%20s:\t%f\t%f\n','Mean',mean_stoi,0);
        fprintf(fw,'%20s:\t%f\t%f\n','Stad',std_stoi,-1);
    end
    fclose(fw);
end
end