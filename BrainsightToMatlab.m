%% Cleaning the environment
clc;
clear;
close all;

%% Processing the text
filename = 'fichiers_test/MS.txt';

% Collecting the headers for the target (if there is ONE target)
targetheaders = findHeaders(filename, 7);
targetvalues = findValues(filename, 8);
target = cell2struct(targetvalues, targetheaders, 2);

%% Collecting the values

headers = findHeaders(filename, 9);
[values, EMG] = findValues(filename, 10);
data = cell2struct(values, headers(1:end-1), 2);
data.(headers(end)) = EMG;