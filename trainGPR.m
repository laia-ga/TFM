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
% false, false, false, false, false]; % knee

% Train a regression model
% This code specifies all the model options and trains the model.
regressionGP = fitrgp(...
    predictors, ...
    response, ...
    'BasisFunction', 'constant', ...
    'KernelFunction', 'matern52', ... %'squaredexponential' o 'matern52' o 'exponential' o 'rationalquadratic'
    'Standardize', true);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
gpPredictFcn = @(x) predict(regressionGP, x);
trainedModel.predictFcn = @(x) gpPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
% trainedModel.RequiredVariables = {'data_normalized1',
% 'data_normalized10', 'data_normalized11', 'data_normalized2',
% 'data_normalized3', 'data_normalized4', 'data_normalized5',
% 'data_normalized6', 'data_normalized7', 'data_normalized8',
% 'data_normalized9'}; % knee
trainedModel.RequiredVariables = {'data_normalized1', 'data_normalized10', 'data_normalized11', 'data_normalized12', 'data_normalized13', 'data_normalized2', 'data_normalized3', 'data_normalized4', 'data_normalized5', 'data_normalized6', 'data_normalized7', 'data_normalized8', 'data_normalized9'}; % hip
trainedModel.RegressionGP = regressionGP;
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
% false, false, false, false, false]; % knee

% Perform cross-validation
partitionedModel = crossval(trainedModel.RegressionGP, 'KFold', 10);

% Compute validation predictions
validationPredictions = kfoldPredict(partitionedModel);

% Compute validation RMSE
validationMSE = kfoldLoss(partitionedModel, 'Mode','individual', 'LossFun', 'mse');
