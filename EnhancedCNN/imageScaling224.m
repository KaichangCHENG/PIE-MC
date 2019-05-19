function output = imageScaling224(input)
% Function: to scale the size of the input image to 224¡Á224¡Á3
%
% Example
% -------
%       output = imageScaling224(input);
%
% Contributed by: Kaichang CHENG, May 15, 2019
%==========================================================================
input = imread(input);
if numel(size(input)) == 2
    input = cat(3,input,input,input);
end
output = imresize(input,[224,224]);