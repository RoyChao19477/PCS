function dr_HASPI(indir,in_filter,cleanFile,clean_filter,HL,Level1)
 if  indir(end) == filesep
      indir=indir(1:(end-1));
  end

  
  filelist=dir(indir);
  filelist2=dir(cleanFile);
  filelist_len=length(filelist);
  
for k=3:filelist_len
      [pathstr,filenamek,ext] = fileparts(filelist(k).name);
      if filelist(k).isdir
           dr_pesq([indir filesep filenamek],in_filter,[cleanFile filesep filenamek],clean_filter);
      else
          if regexp(filelist(k).name,in_filter)
              deg_wav=fullfile(indir, filelist(k).name);
              ref_wav=fullfile(cleanFile, filelist2(k).name);
              [x,fx,nbits]=wavread(ref_wav);
              [y,fy,nbits]=wavread(deg_wav);
              x1=sqrt(mean2(x.^2));
              y1=sqrt(mean2(y.^2))
              x = x/x1;
              y = y/y1;
              [Intel,raw] = HASPI_v1(x,fx,y,fy,HL,Level1);
               HASPI=Intel;
               fw=fopen('e:\Results of benchmarks\HASPI.txt','a');% 儲存路徑
               fprintf(fw,'%f\r\n',HASPI);% 儲存方式
               fclose(fw);               
          end
      end
end