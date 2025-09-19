clc
clear
close all

%cfs2mat.Convert()

%% Looking for the file & loading the data
[file, file_dir] = uigetfile('*.mat');
str_file = convertCharsToStrings(file);
str_file_dir = convertCharsToStrings(file_dir);
str_file_path = str_file_dir + str_file;

tmp = load(str_file_path);
fields_tmp = fieldnames(tmp);
raw_indexed_data = tmp.(fields_tmp{1});
raw_fields = fieldnames(raw_indexed_data);

% Reindexing the structure to use lable easier
data = struct();
for i =1:3
    data.(raw_fields{i}) = raw_indexed_data.(raw_fields{i});
end
for i = 4:numel(raw_fields)
    oldName = raw_fields{i};
    newName = oldName(1:end-2);   % remove last 3 chars
    data.(newName) = raw_indexed_data.(oldName);
end



%% Collecting signals : EMG / Stim

% Collecting the EMG signal and filtrating it, when position is EMG_5 
% TODO: look how to select the adquate signal
EMG = data.EMG.dat;
freq_EMG = data.EMG.FreqS;

% Using SDF's filtering function
EMG_filtered = filtrage(EMG, freq_EMG, 20, 400);

% Collecting stim signal taking into account that the signal is acquired 
% on the ADC0

stim = data.ADC0.dat;
freq_stim = data.ADC0.FreqS;

%% Matching the data in frequency
% taking the EMG's one: freq_EMG

end_time_EMG = length(EMG)*(1/freq_EMG);
time_EMG = linspace(0, end_time_EMG, length(EMG));
new_time_EMG = 0:(1/freq_EMG):end_time_EMG;

end_time_stim = length(stim)*(1/freq_stim);
time_stim = linspace(0, end_time_stim, length(stim));
new_time_stim = 0:(1/freq_EMG):end_time_stim;

new_stim = interp1(time_stim, stim, new_time_stim, 'spline');

%% Looking for the stim times

listOfStim = [] ;
i = 1 ;
while i < length(new_stim)
    if new_stim(i) > 0.5
        listOfStim = [listOfStim, i];
        i = i+300;
    else
        i = i+1;
    end
end

% Determining the window in which the MEP should be (-100, stim, + 500ms)
MEPWindows = [];
for t = 1:length(listOfStim)
    minus = round(listOfStim(t)-0.1*freq_EMG) ; 
    plus = round(listOfStim(t)+0.5*freq_EMG) ;
    if minus < 1
        minus = 1;
    end
    if plus > length(EMG_filtered)
        plus = length(EMG_filtered);
    end

    wdw = [minus, plus];
    MEPWindows = [MEPWindows; wdw];
end


% Collecting all the MEP separately
allMEP = [];
for w = 1:length(MEPWindows)
    fstart = MEPWindows(w,1);
    fend   = MEPWindows(w,2);
    EMG_window = EMG_filtered(fstart:fend);
    allMEP = [allMEP, EMG_window];
end

% Creating a time vector
time =  0:length(allMEP);
% Selecting the MEPs
selectingMEP(allMEP, time);

% 
means = [];
stdDevs = [];
stm = round(0.1*freq_EMG) ; 

for si = 1:size(SelectedMEPs, 2)
    mepSignal = SelectedMEPs(:,si);
    meanValue = mean(mepSignal(1:stm));
    stdValue = std(mepSignal(1:stm));
    means = [means, meanValue];
    stdDevs = [stdDevs, stdValue];
end

filteredSelectedMEP = [];
for smep = 1:size(SelectedMEPs,2)
    MEPF = SelectedMEPs(:, smep)-means(smep);
    filteredSelectedMEP = [filteredSelectedMEP, MEPF];
end

% %% Reaching the number of frames / EMGs
% 
% nb_frames = data.frames;
% nb_EMGs = data.chans;
% 
% %% Concatenating all the frame to have one single, continuous, signal
% 
% val2D = []; %Essai1EMG16plusTMS_wave_data.values(:,:,1)
% for i = 1:nb_frames
%     val2D = [val2D; data.values(:,:,i)];
% end
% 
% %% Creating table for each EMG
% 
% for i = 1:nb_EMGs
%     EMG = val2D(:,i);
%     name_EMG = 'EMG_'+ string(i);
%     EMG_signals.(name_EMG) = EMG;
% end
% 
% %% Creating time
% 
% nb_points = double((data.points)*(nb_frames));
% interval = double(data.interval);
% end_time = double(nb_points*interval);
% time = linspace(0,end_time,nb_points)';
% 
% %% Plotting the EMGs
% 
% list = fieldnames(EMG_signals);
% len = sqrt(length(list));
% if mod(len, 2) == 0
%     n = floor(len);
%     m = floor(len);
% elseif len == 1
%     n = 1, m = 1;
% else
%     n = floor(len)+1;
%     m = floor(len);
% 
% end
% 
% for i = 1:nb_EMGs
%     subplot(n,m,double(i))
%     y = EMG_signals.(list{i})(:);
%     plot(time, y)
%     title(list{i});
% end