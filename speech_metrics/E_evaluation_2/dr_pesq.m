function dr_pesq(indir,in_filter,cleanFile,clean_filter)
% dr_pesq(indir,in_filter,cleanFile,clean_filter)
  if  indir(end) == filesep
      indir=indir(1:(end-1));
  end

  
  filelist=dir(indir);
  filelist2=dir(cleanFile);
  filelist_len=length(filelist);
  
  % filelist(1)='.'        % filelist(2)='..'  should be excluded
  for k=3:filelist_len
      [pathstr,filenamek,ext] = fileparts(filelist(k).name);
      if filelist(k).isdir
           dr_pesq([indir filesep filenamek],in_filter,[cleanFile filesep filenamek],clean_filter);
      else
          if regexp(filelist(k).name,in_filter)
              deg_wav=fullfile(indir, filelist(k).name);
              ref_wav=fullfile(cleanFile, filelist2(k).name);
              pesq(ref_wav, deg_wav)
          end
      end
  end