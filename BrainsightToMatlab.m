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

%% Collecting the values for each try

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

for i = 9:2:numLines - 12
    headers = findHeaders(filename, i);
    [values, EMG] = findValues(filename, i+1);
    oneSample = cell2struct(values, headers(1:end-1), 2);
    oneSample.(headers{end}) = EMG;
    data.(oneSample.(headers{1})) = oneSample(2:end);
end