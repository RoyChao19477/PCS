function dr_HASQI(indir,in_filter,cleanFile,clean_filter,HL,eq,Level1)
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
              [Combined,Nonlin,Linear,raw]=HASQI_v2(x,fx,y,fy,HL,eq,Level1);
               HASQI=Combined;
               fw=fopen('e:\Results of benchmarks\HASQI.txt','a');% �x�s���|
               fprintf(fw,'%f\r\n',HASQI);% �x�s�覡
               fclose(fw);               
          end
      end
end