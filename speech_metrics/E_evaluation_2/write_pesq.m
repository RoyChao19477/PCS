function write_pesq(writetofile,filename,pesq_mos)
        pesq1=pesq_mos;
        fw=fopen(writetofile,'a');
        fprintf(fw,'%20s:\t%f\n',filename,pesq1);
        fclose(fw);
end