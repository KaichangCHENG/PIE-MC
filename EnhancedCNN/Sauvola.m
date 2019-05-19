function output=Sauvola(image, varargin)
% Function: to binarize in situ plankton image based on the Sauvola method
% Input parameter imgTemp is the input grayscale image.
% Output  BW is the binarized image.
%
% Example
% -------
%       output=Sauvola(image);
%
% Contributed by: Kaichang CHENG, May 15, 2019
%==========================================================================
numvarargs = length(varargin);      % only want 3 optional inputs at most
if numvarargs > 3
    error('myfuns:somefun2Alt:TooManyInputs', ...
        'Possible parameters are: (image, [m n], threshold, padding)');
end
optargs = {[3 3] 0.34 'same'}; % set default parameters

optargs(1:numvarargs) = varargin;   % use memorable variable names
[window, k, padding] = optargs{:};

if size(image, 3) == 3
    image = rgb2gray(image);
end

% Convert to double
image = im2double(image);

h=fspecial('average',window);
meanSquare=filter2(h,image,padding);
nhood=ones(window);
deviation=stdfilt(image,nhood);

% Sauvola method
R = max(deviation(:));
threshold = meanSquare.*(1 + k * (deviation / R-1));
output = (image > threshold);
%output= output0((size(image,1)+1)/2,:);
end