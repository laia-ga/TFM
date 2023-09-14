function [trainedModel, validationMSE] = trainRegressionModel(trainingData)
% [trainedModel, validationMSE] = trainRegressionModel(trainingData)
% Returns a trained regression model and its MSE.
%
%  Input:
%      trainingData: A table containing the same predictor and response
%       columns as those imported into the app.
%
%
%  Output:
%      trainedModel: A struct containing the trained regression model. The
%       struct contains various fields with information about the trained
%       model.
%
%      trainedModel.predictFcn: A function to make predictions on new data.
%
%      validationMSE: Matriz con los MSE de validación para cada fold
%


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
% predictorNames = {'data_normalized1', 'data_normalized2',
% 'data_normalized3', 'data_normalized4', 'data_normalized5',
% 'data_normalized6', 'data_normalized7', 'data_normalized8',
% 'data_normalized9', 'data_normalized10', 'data_normalized11'}; % knee
predictorNames = {'data_normalized1', 'data_normalized2', 'data_normalized3', 'data_normalized4', 'data_normalized5', 'data_normalized6', 'data_normalized7', 'data_normalized8', 'data_normalized9', 'data_normalized10', 'data_normalized11', 'data_normalized12', 'data_normalized13'}; % hip
predictors = inputTable(:, predictorNames);
response = inputTable.LOS;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false]; % hip
% isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false]; % knee

% Train a regression model
% This code specifies all the model options and trains the model.
%% Knee SIH1
% regressionNeuralNetwork = fitrnet(...
%     predictors, ...
%     response, ...
%     'LayerSizes', [1 12], ...
%     'Activations', 'none', ...
%     'Lambda', 0.1023554164633213, ...
%     'IterationLimit', 1000, ...
%     'Standardize', false);

%% Knee SIH2
% regressionNeuralNetwork = fitrnet(...
%     predictors, ...
%     response, ...
%     'LayerSizes', [128 219], ...
%     'Activations', 'none', ...
%     'Lambda', 0.05772731785509663, ...
%     'IterationLimit', 1000, ...
%     'Standardize', false);

%% Knee Total
% regressionNeuralNetwork = fitrnet(...
%     predictors, ...
%     response, ...
%     'LayerSizes', [214 9 11], ...
%     'Activations', 'none', ...
%     'Lambda', 4.001009439912746e-07, ...
%     'IterationLimit', 1000, ...
%     'Standardize', true);

%% Hip SIH1
% regressionNeuralNetwork = fitrnet(...
%     predictors, ...
%     response, ...
%     'LayerSizes', [3 74], ...
%     'Activations', 'none', ...
%     'Lambda', 0.1491445015758582, ...
%     'IterationLimit', 1000, ...
%     'Standardize', true); 

%% Hip SIH2
% regressionNeuralNetwork = fitrnet(...
%     predictors, ...
%     response, ...
%     'LayerSizes', 31, ...
%     'Activations', 'relu', ...
%     'Lambda', 0.1951779864491901, ...
%     'IterationLimit', 1000, ...
%     'Standardize', true);

%% Hip Total
regressionNeuralNetwork = fitrnet(...
    predictors, ...
    response, ...
    'LayerSizes', [4 221], ...
    'Activations', 'sigmoid', ...
    'Lambda', 0.0002395078786556258, ...
    'IterationLimit', 1000, ...
    'Standardize', false);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
neuralNetworkPredictFcn = @(x) predict(regressionNeuralNetwork, x);
trainedModel.predictFcn = @(x) neuralNetworkPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
% Add additional fields to the result struct
% trainedModel.RequiredVariables = {'data_normalized1',
% 'data_normalized10', 'data_normalized11', 'data_normalized2',
% 'data_normalized3', 'data_normalized4', 'data_normalized5',
% 'data_normalized6', 'data_normalized7', 'data_normalized8',
% 'data_normalized9'}; % knee
trainedModel.RequiredVariables = {'data_normalized1', 'data_normalized10', 'data_normalized11', 'data_normalized12', 'data_normalized13', 'data_normalized2', 'data_normalized3', 'data_normalized4', 'data_normalized5', 'data_normalized6', 'data_normalized7', 'data_normalized8', 'data_normalized9'}; % hip
trainedModel.RegressionNeuralNetwork = regressionNeuralNetwork;
trainedModel.About = 'This struct is a trained model exported from Regression Learner R2023a.';
trainedModel.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
% predictorNames = {'data_normalized1', 'data_normalized2',
% 'data_normalized3', 'data_normalized4', 'data_normalized5',
% 'data_normalized6', 'data_normalized7', 'data_normalized8',
% 'data_normalized9', 'data_normalized10', 'data_normalized11'}; % knee
predictorNames = {'data_normalized1', 'data_normalized2', 'data_normalized3', 'data_normalized4', 'data_normalized5', 'data_normalized6', 'data_normalized7', 'data_normalized8', 'data_normalized9', 'data_normalized10', 'data_normalized11', 'data_normalized12', 'data_normalized13'}; % hip
predictors = inputTable(:, predictorNames);
response = inputTable.LOS;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false]; % hip
% isCategoricalPredictor = [false, false, false, false, false, false,
% false, false, false, false, false]; & knee

% Perform cross-validation
partitionedModel = crossval(trainedModel.RegressionNeuralNetwork, 'KFold', 10);

% Compute validation predictions
validationPredictions = kfoldPredict(partitionedModel);

% Compute validation RMSE
validationMSE = kfoldLoss(partitionedModel, 'Mode','individual', 'LossFun', 'mse');