function trainingResNet50()
% Function: to finetune ResNet50 on 7 plankton classes, and save the final
%           finetuned model as './network_ResNet50.mat'
%
% Example
% -------
%       trainingResNet50();% Use the default training parameters
%
% Contributed by: Kaichang CHENG, May 15, 2019
%==========================================================================
clear;
close;
net = resnet50;
lgraph = layerGraph(net);

% traing set
imdsTrain = imageDatastore(strcat(pwd,'\dataset\train'),...
    'includeSubfolders',true,...
    'labelsource','foldernames','ReadFcn',@imageScaling224);

T_train = countEachLabel(imdsTrain);
disp(T_train);

% testing set
imdsTest = imageDatastore(strcat(pwd,'\dataset\test'),...
    'includeSubfolders',true,...
    'labelsource','foldernames','ReadFcn',@imageScaling224);

T_test = countEachLabel(imdsTest);
disp(T_test);

lgraph = removeLayers(lgraph, {'fc1000', 'fc1000_softmax','ClassificationLayer_fc1000' });

numClasses = numel(categories(imdsTrain.Labels));
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
lgraph = addLayers(lgraph,newLayers);
lgraph = connectLayers(lgraph,'avg_pool','fc');

layers = lgraph.Layers;
connections = lgraph.Connections;

% Keep the weight of the first 120 layers unchanged
% layers(1:150) = freezeWeights(layers(1:150));
lgraph = createLgraphUsingConnections(layers,connections);
% Make validation set from traing set
[imds1,imds2] = splitEachLabel(imdsTrain,0.8);

%% train
options = trainingOptions('sgdm',...
    'ValidationData',imds2,...
    'ValidationFrequency' ,10,...
    'MiniBatchSize',64,...
    'Maxepochs',5,...
    'InitialLearnRate',0.001,...
    'Shuffle','every-epoch',...
    'Plots','training-progress');

network = trainNetwork(imds1,lgraph,options);

%% predict
tic
predictLabels = classify(network,imdsTest) ;
toc

testLabels = imdsTest.Labels;
% one-hot encoding for testing set
ttest = dummyvar(double(testLabels))' ;
% one-hot encoding for predicting results
tpredictions = dummyvar(double(categorical(predictLabels)))';
% plot confusion matrix
plotconfusion(ttest,tpredictions);
accuracy = mean(predictLabels == testLabels);
disp(['Average accuracy:',num2str(accuracy)]); 
save network_ResNet50.mat network ;% save model
end