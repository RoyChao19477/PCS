function sd=compute_sdi(cleanFile,enhdFile)

x = cleanFile;
xh = enhdFile;

xx=zeros(length(xh),1);
for i=1:length(xh)
  xx(i)=x(i);
end
sd=mean((xx-xh).^2)/mean(xx.^2) ;% SDI
end
