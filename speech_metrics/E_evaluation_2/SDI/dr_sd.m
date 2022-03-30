function dr_sd(indir,in_filter,cleanFile,clean_filter)
  if  indir(end) == filesep
      indir=indir(1:(end-1));
  end
  
  filelist=dir(indir);
  filelist2=dir(cleanFile);
  filelist_len=length(filelist);
  
  % filelist(1)='.'        % filelist(2)='..'  should be excluded
  for k=3:filelist_len
      [pathstr,filenamek,ext,versn] = fileparts(filelist(k).name);
      if filelist(k).isdir
           dr_sd([indir filesep filenamek],in_filter,[cleanFile filesep filenamek],clean_filter);
      else
          if regexp(filelist(k).name,in_filter)
              enhdFile=fullfile(indir, filelist(k).name);
              cleanFile2=fullfile(cleanFile, filelist2(k).name);
              compute_sd(cleanFile2,enhdFile);
          end
      end
  end