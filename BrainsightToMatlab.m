%% Cleaning the environment
clc;
clear;
close all;

%% Processing the text
% Reading the file as a raw text to remove the comments
filename = 'fichiers_test/MS.txt';
filetxt = fopen(filename, 'r');
lines = {};

% Collecting the headers for the target
targetheaders = findHeaders(filetxt, 7);