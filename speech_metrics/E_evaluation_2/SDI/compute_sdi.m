function compute_sdi(cleanFile,enhdFile,writetofile,filename)

x = cleanFile;
xh = enhdFile;

xx=zeros(length(xh),1);
for i=1:length(xh)
  xx(i)=x(i);
end
sd=mean((xx-xh).^2)/mean(xx.^2) ;% SDI
write_sdi(writetofile,filename,sd); 
end
