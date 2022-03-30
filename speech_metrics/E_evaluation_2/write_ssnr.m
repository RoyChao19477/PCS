function write_ssnr(writetofile,filename,ssnr_dB)
        ssnr_dB1=ssnr_dB;
        fw=fopen(writetofile,'a');
        fprintf(fw,'%20s:\t%f\n',filename,ssnr_dB1);
        fclose(fw);
end