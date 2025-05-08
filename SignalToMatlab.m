clc
clear
close all

%cfs2mat.Convert()

%% Looking for the file
[file, file_dir] = uigetfile('*.mat');
str_file = convertCharsToStrings(file);
str_file_dir = convertCharsToStrings(file_dir);
str_file_path = str_file_dir + str_file;

tmp = load(str_file_path);
fields = fieldnames(tmp);
data = tmp.(fields{1});

%% Reaching the number of frames / EMGs

nb_frames = data.frames;
nb_EMGs = data.chans;

%% Concatenating all the frame to have one single, continuous, signal

val2D = []; %Essai1EMG16plusTMS_wave_data.values(:,:,1)
for i = 1:nb_frames
    val2D = [val2D; data.values(:,:,i)];
end

%% Creating table for each EMG

for i = 1:nb_EMGs
    EMG = val2D(:,i);
    name_EMG = 'EMG_'+ string(i);
    EMG_signals.(name_EMG) = EMG;
end