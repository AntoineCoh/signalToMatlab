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

%% Reaching the number of frames

nb_frames = data.frames

%% Concatenating all the frame to have one single, continuous, signal

val2D_t = []; %Essai1EMG16plusTMS_wave_data.values(:,:,1)
for i = 1:9
    val2D_t = [val2D_t; Essai1EMG16plusTMS_wave_data.values(:,:,i)];
end