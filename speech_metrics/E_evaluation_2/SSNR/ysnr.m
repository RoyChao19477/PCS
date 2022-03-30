function ysnr_dB = ysnr(x,xh,y)
% e=x(1:length(xh),:)-y(1:length(xh),:);
e=x(1:size(xh),:)-y(1:size(xh),:);
% a=sum(x(1:length(xh),:).*x(1:length(xh),:),2);
a=sum(x(1:size(xh),:).*x(1:size(xh),:),2);
b=sum(e.*e,2);
for i=1:size(xh)   %length(xh)
    if b(i) == 0
        b(i) = eps;
    end
end
ysnr = a./b;
for i=1:size(xh)  %i=1:length(xh)
    if ysnr(i) == 0
        ysnr(i) = eps;
    end
end
ysnr_dB = 10*log10(ysnr);



