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
% isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false]; % knee

% Train a regression model
% This code specifies all the model options and trains the model.
concatenatedPredictorsAndResponse = predictors;
concatenatedPredictorsAndResponse.LOS = response;
linearModel = fitlm(...
    concatenatedPredictorsAndResponse, ...
    'linear', ...
    'RobustOpts', 'off');  % 'off' para regresión lineal y 'on' para regresión lineal robusta

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
linearModelPredictFcn = @(x) predict(linearModel, x);
trainedModel.predictFcn = @(x) linearModelPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
% trainedModel.RequiredVariables = {'data_normalized1',
% 'data_normalized10', 'data_normalized11', 'data_normalized2',
% 'data_normalized3', 'data_normalized4', 'data_normalized5',
% 'data_normalized6', 'data_normalized7', 'data_normalized8',
% 'data_normalized9'}; % knee
trainedModel.RequiredVariables = {'data_normalized1', 'data_normalized10', 'data_normalized11', 'data_normalized12', 'data_normalized13', 'data_normalized2', 'data_normalized3', 'data_normalized4', 'data_normalized5', 'data_normalized6', 'data_normalized7', 'data_normalized8', 'data_normalized9'}; % hip
trainedModel.LinearModel = linearModel;
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
KFolds = 10;
cvp = cvpartition(size(response, 1), 'KFold', KFolds);

% Inicializa un vector para almacenar los valores de MSE de cada fold
validationMSE = zeros(KFolds, 1);

for fold = 1:KFolds
    trainingPredictors = predictors(cvp.training(fold), :);
    trainingResponse = response(cvp.training(fold), :);
    foldIsCategoricalPredictor = isCategoricalPredictor;

    % Train a regression model
    % This code specifies all the model options and trains the model.
    concatenatedPredictorsAndResponse = trainingPredictors;
    concatenatedPredictorsAndResponse.LOS = trainingResponse;
    linearModel = fitlm(...
        concatenatedPredictorsAndResponse, ...
        'linear', ...
        'RobustOpts', 'off'); % 'off' para linear model y 'on' para robust linear model

    % Create the result struct with predict function
    linearModelPredictFcn = @(x) predict(linearModel, x);
    validationPredictFcn = @(x) linearModelPredictFcn(x);

    % Calcula el MSE para el fold actual
    foldPredictions = validationPredictFcn(predictors(cvp.test(fold), :));
    foldMSE = sum((foldPredictions - response(cvp.test(fold))).^2) / sum(cvp.test(fold));

    % Almacena el valor del MSE en la matriz validationMSE
    validationMSE(fold) = foldMSE;
end
