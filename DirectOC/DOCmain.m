%% Load file with configuration for different trials and run one by one

clc;clear all;close all;

% Add paths to directories with model definition and util functions
setPaths();

% Load json with information about each trial
configFile = jsondecode(fileread('../Data_json/PamelaConfig/DOC_Template.json'));


% Create setup and define continuous functions for GPOPS2
currentTrial = configFile.Trials;
weights = currentTrial.weights;

% Create dynamic model and IOC instance associated to it. This
% instance will be used to compute target features
dynModel = getModel(currentTrial);
dt=0.01;
ioc = IOCInstance(dynModel, dt);
ioc.init(currentTrial);

% Define optimization setup based on json entry
[q, dq, tau, time] = getSplineGuess(dynModel, currentTrial);

currentTrial.guess = struct('jointAngles', q, 'angularVelocities', dq,...
               'control', tau, 'time', time);
continuousFunc = @(input)humanDynContinuousFunc(input, weights, ioc);
setup = defineGPOPSOptimization(currentTrial, continuousFunc);

%  Solve problem using GPOPS2
output = gpops2(setup);

% Extract Solution and save it in data folder
solution = output.result.solution;
time = solution.phase.time;
state = solution.phase.state;
control = solution.phase.control;
% % plot
% figure(1)
% clf
% plot(time,state(:,1:3))
% legend('q1','q2','q3')
% figure(2)
% clf
% plot(time,state(:,4:6))
% figure(3)
% clf
% plot(time,control)
% legend('tau1','tau2','tau3')





