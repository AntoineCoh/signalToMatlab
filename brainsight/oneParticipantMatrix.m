%% Clearing the environment
clc
clear all

%% Collecting the session file
[files, path] = uigetfile('*.txt', 'Sélectionnez les fichiers', 'MultiSelect', 'on');

% Collecting the name of the muscle
prompt = sprintf('Please specify the targeted muscle for this analysis:\n\n/!\\ It has to be the same name that the one given to the target.');
reponse = inputdlg({prompt}, 'Info request', [1 40]);
muscle = reponse{1};  % On récupère le texte saisi
disp(['The targeted muscle is the ' muscle '.']);

%% Collecting the data
% Looking for the file and extracting the data
str_file = convertCharsToStrings(files);
str_file_dir = convertCharsToStrings(path);
str_file_path = str_file_dir + str_file;
data = parseTxtFile(str_file_path);

participant = struct();

% Collecting the time to plot the MEPs then
time = timeDefinition(data);

% Collecting the MEPs in one big matrix
allMEP = mepMatrix(data);

% Collecting the good MEPs

selectedMEPs = selectingMEP(allMEP, time);

%%
nSelectedMEPs = length(selectedMEPs);
n = (1:nSelectedMEPs)';
% Collecting MEP signals for the selected MEPs
MEPSignals = collectingMEP(selectedMEPs);
f = fieldnames(MEPSignals);
participant.('MEP_Signal') = MEPSignals ; 

% Collecting peak to peak values for the selected MEPs
P2P = collectingPeak2Peak(selectedMEPs);
P2PCol = [];
for i = 1:nSelectedMEPs
    P2PCol = [P2PCol; P2P.(f{i})];
end
participant.('Peak2Peak') = P2P ; 

% Collecting latencies  for the selected MEPs
latencies = collectingLatency(selectedMEPs);
latCol = [];
for i = 1:nSelectedMEPs
    latCol = [latCol; latencies.(f{i})];
end
participant.('Latency') = latencies ; 

% Creating muscle columns
muscleCol = repmat({muscle}, nSelectedMEPs, 1);
participant.('Muscle') = muscle;

indexes = {'MEP number', 'Muscle', 'Peak-to-Peak value', 'Latency'};
participantTable = table(n, muscleCol, P2PCol, latCol, VariableNames=indexes);

