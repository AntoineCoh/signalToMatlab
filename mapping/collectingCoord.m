function [X, Y, Z, PP] = collectingCoord(data, muscle)

% function

    % Collecting all the dot of the grid
    grid = struct();
    % m = ;

    for i = 1:length(data.samples)
        if ~isempty(data.samples{1, i}.Assoc__Target)
            targetName = strsplit(data.samples{1, i}.Assoc__Target);
            if length(targetName) > 1 & strcmp(targetName{1}, muscle) & data.samples{1, i}.Loc__Z~=-78
                sampleName = matlab.lang.makeValidName(data.samples{1, i}.Sample_Name);
                grid.(sampleName).Loc_X = data.samples{1, i}.Loc__X;
                grid.(sampleName).Loc_Y = data.samples{1, i}.Loc__Y;
                grid.(sampleName).Loc_Z = data.samples{1, i}.Loc__Z;
                grid.(sampleName).EMG_PP = data.samples{1, i}.EMG_Peak_to_peak_1;
                grid.(sampleName).Latency = data.samples{1, i}.EMG_Latency_1;
                grid.(sampleName).Assoc_Target = data.samples{1, i}.Assoc__Target;
            end
        else
            continue
        end
    end
    
    fields = fieldnames(grid);
    assocTargets = cellfun(@(f) grid.(f).Assoc_Target, fields, 'UniformOutput', false);
    
    % Find unique Assoc_Target entries
    [~, ia] = unique(assocTargets, 'stable');
    uniqueFields = fields(ia);
    
    % Create a new struct with only unique entries
    grid_unique = struct();
    for i = 1:numel(uniqueFields)
        grid_unique.(uniqueFields{i}) = grid.(uniqueFields{i});
    end

    grid = grid_unique;  % Replace original with deduplicated version


    % Collecting X, Y, Z coordinates
    grid_points = fieldnames(grid);
    X = [];
    Y = [];
    Z = [];
    PP = [];
    
    for i = 1:length(grid_points)
        X = [X, grid.(grid_points{i}).Loc_X];
        Y = [Y, grid.(grid_points{i}).Loc_Y];
        Z = [Z, grid.(grid_points{i}).Loc_Z];
        PP = [PP, grid.(grid_points{i}).EMG_PP];
    end
    
end
