%% Cleaning the environment
clc;
clear;
close all;

%% Processing the text file for test
filename = 'fichiers_test/MS.txt';

%% Looking for the file
[file, file_dir] = uigetfile('*.txt');
str_file = convertCharsToStrings(file);
str_file_dir = convertCharsToStrings(file_dir);
str_file_path = str_file_dir + str_file;

filename = str_file_path;

% Looking for the number of lines in the file
fid = fopen(filename, 'r');
if fid == -1
    error('Failed to open the file: %s', filename);
end
numLines = 0;
while ~feof(fid)
    fgetl(fid);  % Read and discard each line
    numLines = numLines + 1;
end
fclose(fid);

%% Collecting the headers for the target (if there is ONE target)
fid = fopen(filename, 'r');

targetheaders = findHeaders(filename, 7);
targetvalues = findValues(filename, 8);
target = cell2struct(targetvalues, targetheaders, 2);

%% Collecting the values for each try

headers = findHeaders(filename, 9);

for d = 10:numLines - 12
    [values, EMG] = findValues(filename, d);
    oneSample = cell2struct(values, headers, 2);
    if EMG ~= 1
        oneSample.(headers{end}) = EMG;
        % Converting the values in numerical values
        EMG = cellfun(@str2double,splitDat);
    end 
    
end