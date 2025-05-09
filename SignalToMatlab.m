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

%% Creating time

nb_points = double(length(EMG));
interval = double(data.interval);
end_time = double(nb_points*interval);
time = linspace(0,end_time,nb_points)';

%% Plotting the EMGs

list = fieldnames(EMG_signals);
len = sqrt(length(list));
if mod(len, 2) == 0
    n = floor(len);
    m = floor(len);
elseif len == 1
    n = 1, m = 1;
else
    n = floor(len)+1;
    m = floor(len);

end

for i = 1:nb_EMGs
    subplot(n,m,double(i))
    y = EMG_signals.(list{i})(:);
    plot(time, y)
    title(list{i});
end