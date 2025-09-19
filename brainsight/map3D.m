%% Plotting a 3D map

X_MEPs = [];
Y_MEPs = [];
meanMEPs = [];

fieldNames = fieldnames(S);
n = length(fieldNames);

for i = 1:n
    pk2pk = [];

    intraFieldNames = fieldnames(S.(fieldNames{i}));

    for j = 1:length(intraFieldNames)
        pk2pk = [pk2pk, S.(fieldNames{i}).(intraFieldNames{j}).EMG_Peak_to_peak_1];
    end

    numStr = regexp(S.(fieldNames{i}).(intraFieldNames{j}).Assoc__Target, '\((.*?)\)', 'tokens');
    numbers = str2double(strsplit(numStr{1}{1}, ','));

    X_MEPs = [X_MEPs; numbers(1)];
    Y_MEPs = [Y_MEPs; numbers(2)];
    meanMEPs = [meanMEPs; mean(pk2pk)];

end

figure
subplot(2,1,1);
s = scatter3(X_MEPs, Y_MEPs, meanMEPs, 60, meanMEPs, 'filled');
colormap(jet);   % ou 'hot' pour retrouver les couleurs du logiciel
cb = colorbar;
cb.Label.String = 'Peak-to-peak amplitude (mV)';

title(['3D map'])

xlabel('X')
ylabel('Y')
zlabel('Z')

% Sort data
[~, idx] = sortrows([X_MEPs Y_MEPs]);
X_sorted = X_MEPs(idx);
Y_sorted = Y_MEPs(idx);
mean_sorted = meanMEPs(idx);

% Get unique coordinates, i.e. [0, 1, 2]
x_unique = unique(X_sorted);
y_unique = unique(Y_sorted);

[X_grid, Y_grid] = meshgrid(x_unique, y_unique);
Z_grid = reshape(mean_sorted, length(y_unique), length(x_unique));
mesh(X_grid, Y_grid, Z_grid);
xlabel('X');
ylabel('Y');
zlabel('Mean');
title('3D Mesh Plot');

% Define a finer grid
xq = linspace(min(X_grid(:)), max(X_grid(:)), 50);  
yq = linspace(min(Y_grid(:)), max(Y_grid(:)), 50);  
[Xq, Yq] = meshgrid(xq, yq);
Zq = interp2(X_grid, Y_grid, Z_grid, Xq, Yq, 'cubic');  % 'linear', 'cubic', or 'spline'
figure
mesh(Xq, Yq, Zq)
xlabel('X'), ylabel('Y'), zlabel('Z')
title('3D mapping')
