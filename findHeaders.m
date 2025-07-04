function headersList = findHeaders(filename, headerLineNumber)
    % Reading the file as a raw text to remove the comments
    fid = fopen(filename, 'r');   % opening the file

    % Finding the line 
    for i = 1:headerLineNumber
        line = fgetl(fid);
    end
    fclose(fid);   % closing the file

    % Erasing the "#" if the line is in comment
    line = strtrim(erase(line, '#'));

    % Splitting the values
    rawHeaders = strsplit(line, '\t');

    headersList = cell(size(rawHeaders));
    % Formating the list of char into a list of double
    for i = 1:length(rawHeaders)
        % Replace spaces and dots with underscores, remove non-word characters
        headersList{i} = matlab.lang.makeValidName(rawHeaders{i});
    end
end