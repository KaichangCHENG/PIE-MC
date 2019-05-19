function trainingResNet50_SVM()
% Function: to finetune ResNet50_SVM on 7 plankton classes based on the 
%           finetuned model 'network_ResNet50', and save the final
%           finetuned model as './network_ResNet50_SVM.mat'
%
% Example
% -------
%       trainingResNet50_SVM();% Use the default training parameters
%
% Contributed by: Kaichang CHENG, May 15, 2019
%==========================================================================
clear;
close all;
net=load('network_ResNet50.mat');
network=net.network;

% Use the output of the K-th layer of ResNet50 as the input feature of SVM
K='avg_pool';

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

trainFeatures = activations(network,imdsTrain,K);

% Save learned features
save trainFeatures.mat trainFeatures ;

%% train multi-class SVM model

% Remove singleton dimensions of training features
features=squeeze(trainFeatures);
% Change it to cell type
TLable=cellstr(string(imdsTrain.Labels));
svm = fitcecoc(features',TLable);

% Save multi-class SVM model
save network_ResNet50_SVM.mat svm network;

%% predict
tic
% Activate the output features at K-th layer of ResNet50
testFeatures = activations(network,imdsTest,K);
Tfeatures=squeeze(testFeatures);

testPredictions = predict(svm,Tfeatures');
toc
% one-hot encoding for testing set
ttest = dummyvar(double(imdsTest.Labels))' ;
% one-hot encoding for predicting results
tpredictions = dummyvar(double(categorical(testPredictions)))';
% plot confusion matrix
plotconfusion(ttest,tpredictions);

% Calculate the accuracy
accuracy = sum(imdsTest.Labels == testPredictions)/numel(imdsTest.Labels);
disp(['Average accuracy:',num2str(accuracy)])
end