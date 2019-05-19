function BW = binarizationMSER( imgTemp )
% Function: to binarize in situ plankton image based on the MSER
% Input parameter imgTemp is the input grayscale image.
% Output  BW is the binarized image.
%
% Example
% -------
%       BW = binarizationMSER( imgTemp );
%
% Contributed by: Kaichang CHENG, May 15, 2019
%==========================================================================
mserRegions = detectMSERFeatures(imgTemp, 'RegionAreaRange',[5000 1000000],...
    'MaxAreaVariation', 1, 'ThresholdDelta', 2);
if isempty(mserRegions) == 1
    BW = true(size(imgTemp));
else
    if length(mserRegions) == 1
        mserRegionsPixels = vertcat(mserRegions.PixelList);
    else
        mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
    end
    mserMask = false(size(imgTemp));
    ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
    mserMask(ind) = true;
    %next step clear binary image using imclearborder, imfill
    %bw1 = imclearborder(mserMask, 4);
    BW = imfill(mserMask, 'holes');
end

end
