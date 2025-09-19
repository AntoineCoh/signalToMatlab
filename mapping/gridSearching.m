%% Collecting only the grid

l = length(targetData.Loc_X);
grid = [];

for i = 1:l
    if startsWith(targetData.TargetName{i}, 'Sample')
        continue
    else
        grid = [grid i];
    end
end

figure
plot3(targetData.Loc_X(grid), targetData.Loc_Y(grid), targetData.Loc_Z(grid), ...
    '.',  50, targetData. 'filled')
text(targetData.Loc_X(grid), targetData.Loc_Y(grid), targetData.Loc_Z(grid), ...
    targetData.TargetName(grid), 'FontSize', 7)
xlabel('Loc. X')
ylabel('Loc. Y')
zlabel('Loc. Z')
