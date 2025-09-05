%% Clearing the environment
clc
clear all

%% Collecting the session file
[files, path] = uigetfile('*.txt', 'Sélectionnez les fichiers', 'MultiSelect', 'on');

% Collecting the name of the muscle
reponse = inputdlg('Targeted muscle:', 'Info request', [1 40]);
muscle = reponse{1};  % On récupère le texte saisi
disp(['The targeted muscle is the ' muscle '.']);

%% Collecting the data
% Looking for the file and extracting the data
str_file = convertCharsToStrings(files);
str_file_dir = convertCharsToStrings(path);
str_file_path = str_file_dir + str_file;
data = parseTxtFile(str_file_path);

% Collecting the good MEPs
selectedMEP = selectingMEP(data);
nSelectedMEPs = 

% Collecting peak to peak values for the selected MEPs
P2P = collectingPeak2Peak(selectedMEP);

% Collecting latencies  for the selected MEPs
lantencies = collectingLatency(selectedMEP);

% Creating muscle columns
muscleCol = repmat({muscle}, nSelectedMEPs, 1);
