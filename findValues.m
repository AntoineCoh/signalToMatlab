function [valuesList, EMG] = findValues(filename, N)
    % Reading the file as a raw text to remove the comments
    filetxt = fopen(filename, 'r');   % opening the file

    % Finding the line 
    for i = 1:N
        line = fgetl(filetxt);
    end
    fclose(filetxt);   % closing the file

    % Erasing the "#" if the line is in comment
    line = strtrim(erase(line, '#'));

    % Splitting the values
    valuesList = strsplit(line, '\t');

    % Formating the list of char into a list of double
    for i = 2:numel(valuesList)-1
        valuesList{i} = str2double(valuesList{i});
    end

    % Reaching the column of the EMG
    iEMG = numel(valuesList);
    dat = valuesList(iEMG);
    splitDat = strsplit(dat{1}, ';');
    % Converting the values in numerical values
    EMG = cellfun(@str2double,splitDat);

    % Removing the cell of the EMG because comes apart
    valuesList = valuesList(1:end-1);
end