function EVALUATION_MAIN(indir1,indir2,indir3,outdir,outfilename)

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

for k=3:filelist_len
    [pathstr_1,filenamek_1,ext_1] = fileparts(filelist_1(k).name);
    [pathstr_2,filenamek_2,ext_1] = fileparts(filelist_2(k).name);
    [pathstr_3,filenamek_3,ext_1] = fileparts(filelist_3(k).name);
    if filelist_1(k).isdir
        EVALUATION_MAIN([indir1 filesep filenamek_1],[indir2 filesep filenamek_2],[indir3 filesep filenamek_3],outdir)
    else
        
        CleanDataFile=fullfile(indir1, filelist_1(k).name);
        NoisyDataFile=fullfile(indir2, filelist_2(k).name);
        EnhadDataFile=fullfile(indir3, filelist_3(k).name);
        
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
        sdi(k)=compute_sdi(CleanData,EnhadData);
        write_sdi(sprintf('%s%sSDI_%s.txt',outdir,filesep,outfilename),filelist_1(k).name,sdi(k));
        % SSNR
        if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
            ssnr_dB(k)=ssnr(EnhadData,NoisyData,CleanData,len);
            write_ssnr(sprintf('%s%sSSNR_%s.txt',outdir,filesep,outfilename),filelist_1(k).name,ssnr_dB(k));
        end
        %HASQI
        [Combined,Nonlin,Linear,raw]=HASQI_v2(CleanData,fc,EnhadData,fe,HL,eq,Level1);
        HASQI(k)=Combined;
        fw=fopen(sprintf('%s%sHASQI_%s.txt',outdir,filesep,outfilename),'a');
        fprintf(fw,'%20s:\t%f\n',filelist_1(k).name,HASQI(k));
        fclose(fw);
        %HASPI
        [Intel,raw] = HASPI_v1(CleanData,fc,EnhadData,fe,HL,Level1);
        HASPI(k)=Intel;
        fw=fopen(sprintf('%s%sHASPI_%s.txt',outdir,filesep,outfilename),'a');
        fprintf(fw,'%20s:\t%f\n',filelist_1(k).name,HASPI(k));
        fclose(fw);
        %PESQ
        pesq_mos(k)=pesq(CleanData, EnhadData);
        write_pesq(sprintf('%s%sPESQ_%s.txt',outdir,filesep,outfilename),filelist_1(k).name,pesq_mos(k));
        
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
    
    % write to file
    write_sdi(sprintf('%s%sSDI_%s',outdir,filesep,outfilename),'Mean',mean_sdi);
    write_sdi(sprintf('%s%sSDI_%s',outdir,filesep,outfilename),'Stad',std_sdi);
    if((length(NoisyData) ~= length(EnhadData)) || (sum(NoisyData-EnhadData) ~= 0))
        write_ssnr(sprintf('%s%sSSNR_%s',outdir,filesep,outfilename),'Mean',mean_ssnr);
        write_ssnr(sprintf('%s%sSSNR_%s',outdir,filesep,outfilename),'Stad',std_ssnr);
    end
    write_pesq(sprintf('%s%sPESQ_%s',outdir,filesep,outfilename),'Mean',mean_pesq);
    write_pesq(sprintf('%s%sPESQ_%s',outdir,filesep,outfilename),'Stad',std_pesq);
    fw=fopen(sprintf('%s%sHASQI_%s',outdir,filesep,outfilename),'a');
    fprintf(fw,'%20s:\t%f\n','Mean',mean_hasqi);
    fprintf(fw,'%20s:\t%f\n','Stad',std_hasqi);
    fclose(fw);
    fw=fopen(sprintf('%s%sHASPI_%s',outdir,filesep,outfilename),'a');
    fprintf(fw,'%20s:\t%f\n','Mean',mean_haspi);
    fprintf(fw,'%20s:\t%f\n','Stad',std_haspi);
    fclose(fw);
end
end