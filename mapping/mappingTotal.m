%% Clearing the environment
clc
clear all
%% Script to plot the maps
[files, path] = uigetfile('*.txt', 'Sélectionnez les fichiers', 'MultiSelect', 'on');

coord = struct();
Sessions = [];

% collecting if several files have been selected:
if isa(files, 'cell')
    n = length(files);
else
    n = 1;
end

% Collecting the name of the muscle
reponse = inputdlg('Targeted muscle:', 'Info request', [1 40]);
muscle = reponse{1};  % On récupère le texte saisi
disp(['The targeted muscle is the ' muscle '.']);

% Collecting the data
str_file = convertCharsToStrings(files);
str_file_dir = convertCharsToStrings(path);
str_file_path = str_file_dir + str_file;
data = parseTxtFile(str_file_path);
[X, Y, Z, PP] = collectingCoord(data, muscle);

%%
if n > 1
    for i = 1:length(files)
        sess = "Session" + num2str(i);
        Sessions = [Sessions, sess];
        coord.X.(sess) = X;
        coord.Y.(sess) = Y;
        coord.Z.(sess) = Z;
        coord.PP.(sess) = PP;
        figure
        plottingTheMap(X, Y, Z, PP, muscle, i)
    end

    % Plotting the average map
    XX = zeros(size(coord.X.(Sessions(1))));
    YY = zeros(size(coord.Y.(Sessions(1))));
    ZZ = zeros(size(coord.Z.(Sessions(1))));
    PPP = zeros(size(coord.PP.(Sessions(1))));

    for i = 1:n
        XX = XX + coord.X.(Sessions(i));
        YY = YY + coord.Y.(Sessions(i));
        ZZ = ZZ + coord.Z.(Sessions(i));
        PPP = PPP + coord.PP.(Sessions(i));
    end
    XX = XX/n ;
    YY = YY/n;
    ZZ = ZZ/n;
    PPP = PPP/n;

    figure
    plottingTheMap(XX, YY, ZZ, PPP, muscle)

else
    sess = "Session";
    coord.X.(sess) = X;
    coord.Y.(sess) = Y;
    coord.Z.(sess) = Z;
    coord.PP.(sess) = PP;
    figure
    plottingTheMap(X, Y, Z, PP, muscle, 1)

end