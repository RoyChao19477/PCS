function write_sdi(writetofile,filename,sd)
        sd1=sd;
        fw=fopen(writetofile,'a');
        fprintf(fw,'%20s:\t%f\n',filename,sd1);
        fclose(fw);
end