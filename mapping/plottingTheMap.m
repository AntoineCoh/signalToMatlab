%% Plotting a 3D map

function plot = plottingTheMap(X, Y, Z, PP, muscle, option)
% take as input a .mat files from the extraction done by the paseTxtFile
    % X: vector containing the x-values of the all the map's points [array]
    % Y: vector containing the y-values of the all the map's points [array]
    % Z: vector containing the z-values of the all the map's points [array]
    % PP: vector containing the EMG pk-to-pk values of the all the map's
    % points [array]
    % muscle: the targeted muscle [char]
    % option: if plotting the map of one session, enter the number of the
    % session [num]
    %         if plotting the mean map from all sessions, enter noting at that position  


    % figure()
    subplot(2,1,1);
    s = scatter3(X, Y, Z, 60, PP, 'filled');
    colormap(jet);   % ou 'hot' pour retrouver les couleurs du logiciel
    cb = colorbar;
    cb.Label.String = 'Peak-to-peak amplitude (mV)';
    if nargin < 6 || isempty(option)
        title(['Plot of the mean cortical map for the ' muscle])
    else
        sessionNb = option;
        str_sessionNb = num2str(sessionNb);
        title(['Plot of the cortical map for the ' muscle ' for the session ' str_sessionNb])
    end

    xlabel('X')
    ylabel('Y')
    zlabel('Z')


    % Smoothed map
    DT = delaunayTriangulation(X', Y', Z'); % X, Y, Z vectors must be in column
    [K, v] = convexHull(DT);
    
    % figure;
    subplot(2,1,2);
    trisurf(K, X', Y', Z', PP', 'EdgeColor', 'none');    % X, Y, Z, and PP vectors must be in column
    colorbar;
    shading interp; % This gives you the smooth color transitions
    camlight; lightig gouraud;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('3D TMS Surface Map');

end