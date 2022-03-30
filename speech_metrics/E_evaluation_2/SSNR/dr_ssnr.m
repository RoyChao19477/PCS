function dr_ssnr(indir,in_filter,in1dir,in1_filter,speech,speech_filter,len)
  if  indir(end) == filesep
      indir=indir(1:(end-1));
  end
  
  filelist=dir(indir);
  filelist2=dir(in1dir);
  filelist_len=length(filelist);
  
  % filelist(1)='.'        % filelist(2)='..'  should be excluded
  for k=3:filelist_len
      [pathstr,filenamek,ext,versn] = fileparts(filelist(k).name);
      if filelist(k).isdir
           dr_ssnr([indir filesep filenamek],in_filter,[in1dir filesep filenamek],in1_filter,[speech filesep filenamek],speech_filter,len);
      else
          if regexp(filelist(k).name,in_filter)
              outfile=fullfile(indir, filelist(k).name);
              noisy=fullfile(in1dir, filelist2(k).name);
              speech2=fullfile(speech, filelist(k).name);
              ssnr(outfile,noisy,speech2,len)
          end
      end
  end