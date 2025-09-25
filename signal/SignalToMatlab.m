%% Details about the code
%{
    This script enables to select and collect MEP
    wished to be analysed from EMG data collected 
    with the CED1401 system and Signal software.

    For now, it asks for one .mat file. Hence, the
    .cfs file from Signal should have already been
    converted through Fabien's function: 
                                    'readCFSfile.m'
    This latter function does not work on Mac.

    * * * * *

    If any issue, please ask me.
    Mathilde
%}


%% Clearing the environment
clc
clear
close all


%% Looking for the file & loading the data
[file, file_dir] = uigetfile('*.mat');
str_file = convertCharsToStrings(file);
str_file_dir = convertCharsToStrings(file_dir);
str_file_path = str_file_dir + str_file;

tmp = load(str_file_path);
fields_tmp = fieldnames(tmp);
raw_indexed_data = tmp.(fields_tmp{1});
raw_fields = fieldnames(raw_indexed_data);

% Reindexing the structure to use labels easier
data = struct();
for i =1:3
    data.(raw_fields{i}) = raw_indexed_data.(raw_fields{i});
end
for i = 4:numel(raw_fields)
    oldName = raw_fields{i};
    newName = oldName(1:end-2);   % removes the last 2 chars ('_X')
    data.(newName) = raw_indexed_data.(oldName);
end



%% Collecting signals : EMG / Stim

% Collecting the EMG signal and filtrating it
% TODO: can have several EMG channels
%       => look how to select the adquate signal
EMG = data.EMG.dat;
freq_EMG = data.EMG.FreqS;

% Using Silvère's filtering function
EMG_filtered = filtrage(EMG, freq_EMG, 20, 400);

% Collecting stim signal considering
% the signal is acquired on the ADC0
stim = data.ADC0.dat;
freq_stim = data.ADC0.FreqS;

%% Matching the data in frequency
% used frequency = EMG's one = freq_EMG


end_time_EMG = length(EMG)*(1/freq_EMG);
time_EMG = linspace(0, end_time_EMG, length(EMG));
new_time_EMG = 0:(1/freq_EMG):end_time_EMG;

end_time_stim = length(stim)*(1/freq_stim);
time_stim = linspace(0, end_time_stim, length(stim));
           % actual time vector of the recorder stim
new_time_stim = 0:(1/freq_EMG):end_time_stim;
           % new time vector of the stim matchnig the frequency of the EMG

% Interpolation
new_stim = interp1(time_stim, stim, new_time_stim, 'spline');
           % interpolates the stim signal ('stim') on the new time vector
           % ('new_time_stim')

%% Looking for the stim times

listOfStim = [] ;   % list of all the stimulation times
i = 1 ;
while i < length(new_stim)
    if new_stim(i) > 0.5    % looks when the stim signal is above 0.5V
        listOfStim = [listOfStim, i];   % if so, collect time of moment
        i = i+300;  % goes far enough to be back in a time window where
                    % stim signal is < 0.5V
    else
        i = i+1;    % if not, looks for the next piece of signal
    end
end

%% Looking for the MEP windows
% Determining the window in which the MEP should be (stim-100 ms, stim+500 ms)

MEPWindows = [];
for t = 1:length(listOfStim)
    minus = round(listOfStim(t)-0.1*freq_EMG) ; % time of stim-100ms
    plus = round(listOfStim(t)+0.5*freq_EMG) ;  % time of stim+500ms
    if minus < 1    % checks if the minus is not < 0,
                    % i.e. not before the acquired data
        minus = 1;
    end
    if plus > length(EMG_filtered)  % checks if the plus is not outside
                                    % the acquired data window
        plus = length(EMG_filtered);
    end

    wdw = [minus, plus];            % sets the window around the stim time
    MEPWindows = [MEPWindows; wdw]; % collect the windows
end


% Collecting all the MEP separately
allMEP = [];    % will store all the MEP within their predetermined windows
for w = 1:length(MEPWindows)
    fstart = MEPWindows(w,1);   % for the window w, takes the starting time
    fend   = MEPWindows(w,2);   % for the window w, takes the ending time
    EMG_window = EMG_filtered(fstart:fend); % collects the window in the
                                            % EMG signal
    allMEP = [allMEP, EMG_window];  % collects it
end

% Creating a time vector (needed for plotting)
time =  linspace(-100,500, (length(allMEP)));
% Selecting the MEPs
[selectedMEPs, selectedIdx] = selectingMEP(allMEP, time);

structMEPs = namingMEP(selectedMEPs, selectedIdx);   % creates a struct,
                                                    % if needed later




%% Analyse of the MEPS
% pas fini / pas prendre en considération ou à améliorer

means = [];
stdDevs = [];
stm = round(0.1*freq_EMG) ; 

for si = 1:size(selectedMEPs, 2)
    mepSignal = selectedMEPs(:,si);
    meanValue = mean(mepSignal(1:stm));
    stdValue = std(mepSignal(1:stm));
    means = [means, meanValue];
    stdDevs = [stdDevs, stdValue];
end

filteredSelectedMEP = [];
for smep = 1:size(selectedMEPs,2)
    MEPF = selectedMEPs(:, smep)-means(smep);
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