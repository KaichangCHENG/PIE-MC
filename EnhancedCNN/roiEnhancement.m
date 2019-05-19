function outROI = roiEnhancement(inROI)
% Function: to suppress the background of ROI.
% Input parameter inROI is the original ROI, and roiBW is the binarized
% ROI.
% Output outROI is the ROI with background suppressed.
%
% Example
% -------
%      outROI = roiEnhancement(inROI);
%
% Contributed by: Kaichang CHENG, May 15, 2019
%==========================================================================
% figure,
% subplot(121);imshow(inROI),title('Original ROI');
sz=size(inROI);
m=round(sz(1)*0.02);
n=round(sz(2)*0.02);
% kepp them to be odd numbers
if rem(m,2)==0
    m=m+1;
end
if rem(n,2)==0
    n=n+1;
end

inROI0=padarray(inROI,[(m-1)/2,(n-1)/2],'replicate','both');
roiBW0 = ~Sauvola(inROI0,[m,m],0.34);
validBW=zeros(sz);
Tv=floor(sqrt(2*(floor(sqrt(m*n))).^2))-2;
for i=1:sz(1)
    for j=1:sz(2)
        mat=roiBW0(i:(i+m-1),j:(j+n-1));
        validBW(i,j)=length(find(mat>0));
    end
end
roiBW1=false(sz);
roiBW1(find(validBW>Tv))=1;

delta=3.7; % keep 3<= delta <=4
[row,clo]=find(roiBW1==1);
tempROI=inROI;
tempROI(sub2ind(size(inROI),row,clo))=255; % set the target to the largest pixel intensity
[sortedROI,ind]=sort(tempROI(:));      % sort them from smallest to largest
sortedBackground=sortedROI(1:(end-length(row)));
Pmin=min(sortedBackground);
Pmax=max(sortedBackground);
Tb=Pmin+(Pmax-Pmin)/delta;
newBackground=uint8(sortedBackground+5*(sortedBackground-Tb)*(delta-3));
inROI(ind(1:(end-length(row))))=newBackground;% replace the background with new ones

outROI=inROI;
%subplot(122),imshow(outROI),title('Enhanced ROI with background suppression');

end
