function [propROI, outBW] = roiExtraction(im)
% Function: to execute potential ROIs in the in situ plankton image based
%           on the Sauvola's method.
% Input parameter im is the input grayscale image.
% Output propROI saves the position (x,y,width,height) of the rectangular,
% and BW is the binarized image.
%
% Example
% -------
%       [propROI, BW] = roiExtraction(im);
%
% Contributed by: Kaichang CHENG, May 15, 2019
%==========================================================================
img=im2double(im);
M=mean(img,'all');
% Calculate Mean Signal-to-Noise Ratio (MSNR)
MSNR=max((img-M).^2,[],'all');
sz=size(img);
if MSNR>0.1
    BW = binarizationMSER( img );
else
    % the size of sliding window
    m=round(sz(1)*0.2);
    n=round(sz(2)*0.2);
    if rem(m,2)==0
        m=m+1;
    end
    if rem(n,2)==0
        n=n+1;
    end
    
    imag = padarray(img,[(m-1)/2,(n-1)/2],'replicate','both');
    
    BW = Sauvola(imag,[m,n],0.34);
    BW=BW(((m+1)/2:(end-(m-1)/2)),((n+1)/2:(end-(n-1)/2)));
end
tempBinary = imcomplement(BW);

area=200;
tempBW = bwareaopen(tempBinary, area);
outBW = imfill(tempBW,'holes');
propROI = regionprops(outBW, 'boundingbox');

%% to display the ROIs with rectangles
% figure(2),imshow(outBW)
% lenROI = size(propROI, 1);
% for idxROI = 1: lenROI
%     cropBox =(propROI(idxROI).BoundingBox);
%     figure(2),rectangle('position', cropBox, 'edgecolor', 'r','LineWidth',1);
%     figure(2),text(cropBox(1)+5, min(cropBox(2)+15,sz(1)-15), num2str(idxROI), 'color', 'g' ,'FontSize',11);
%     drawnow();
% end

end

