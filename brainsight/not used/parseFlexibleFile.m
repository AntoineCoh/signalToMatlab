function [targetData, sampleData] = parseFlexibleFile(filename)
    % Parse files that can have two different structures:
    % Type 1: Target info + Sample data with different headers
    % Type 2: Multiple targets + Sample data after "# Sample Name" header
    
    % Read the entire file
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file: %s', filename);
    end
    
    % Read all lines
    lines = {};
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            lines{end+1} = line;
        end
    end
    fclose(fid);
    
    % Initialize output structures
    targetData = [];
    sampleData = [];
    
    % Find key header lines
    targetHeaderIdx = [];
    sampleHeaderIdx = [];
    
    for i = 1:length(lines)
        line = lines{i};
        
        % Look for target header (starts with "# Target Name")
        if startsWith(line, '# Target Name')
            targetHeaderIdx = i;
        end
        
        % Look for sample header (starts with "# Sample Name")
        if startsWith(line, '# Sample Name')
            sampleHeaderIdx = i;
        end
    end
    
    % Parse based on which headers we found
    if ~isempty(targetHeaderIdx) && ~isempty(sampleHeaderIdx)
        % Type 2: Both headers present
        fprintf('Detected Type 2 file format\n');
        [targetData, sampleData] = parseType2Fixed(lines, targetHeaderIdx, sampleHeaderIdx);
        
    elseif ~isempty(targetHeaderIdx) && isempty(sampleHeaderIdx)
        % Type 1: Only target header, need to find where sample data starts
        fprintf('Detected Type 1 file format\n');
        [targetData, sampleData] = parseType1(lines, targetHeaderIdx);
        
    else
        error('Could not identify file format - no recognizable headers found');
    end
end

function [targetData, sampleData] = parseType2Fixed(lines, targetHeaderIdx, sampleHeaderIdx)
    % Parse Type 2 files: Handle target and sample sections separately
    
    % Parse target section
    targetHeader = lines{targetHeaderIdx};
    targetColumns = strsplit(targetHeader(3:end), '\t'); % Remove "# "
    
    % Get target data lines (only the lines that match target column count)
    targetDataLines = {};
    for i = (targetHeaderIdx + 1):(sampleHeaderIdx - 1)
        line = lines{i};
        if ~isempty(strtrim(line)) && ~startsWith(line, '#')
            % Check if this line has the right number of columns for target data
            values = strsplit(line, '\t');
            if length(values) == length(targetColumns)
                targetDataLines{end+1} = line;
            else
                % Skip lines that don't match target format (like notes)
                fprintf('Skipping line with %d values (expected %d for target): %s\n', ...
                    length(values), length(targetColumns), line);
            end
        end
    end
    
    % Parse target data
    targetData = parseDataSection(targetDataLines, targetColumns);
    
    % Parse sample section
    sampleHeader = lines{sampleHeaderIdx};
    sampleColumns = strsplit(sampleHeader(3:end), '\t'); % Remove "# "
    
    % Get sample data lines (after sample header)
    sampleDataLines = {};
    for i = (sampleHeaderIdx + 1):length(lines)
        line = lines{i};
        if ~isempty(strtrim(line)) && ~startsWith(line, '#')
            % Check if this line has the right number of columns for sample data
            values = strsplit(line, '\t');
            if length(values) == length(sampleColumns)
                sampleDataLines{end+1} = line;
            else
                fprintf('Skipping sample line with %d values (expected %d): %s\n', ...
                    length(values), length(sampleColumns), line);
            end
        end
    end
    
    % Parse sample data
    sampleData = parseDataSection(sampleDataLines, sampleColumns);
end

function [targetData, sampleData] = parseType1(lines, targetHeaderIdx)
    % Parse Type 1 files: Target info first, then sample data with different structure
    
    % Parse target header
    targetHeader = lines{targetHeaderIdx};
    targetColumns = strsplit(targetHeader(3:end), '\t'); % Remove "# "
    
    % Find target data (non-comment lines after target header until we hit sample data)
    targetDataLines = {};
    sampleStartIdx = [];
    
    for i = (targetHeaderIdx + 1):length(lines)
        line = lines{i};
        
        % Skip empty lines
        if isempty(strtrim(line))
            continue;
        end
        
        % If we hit a comment line, this might be start of sample section
        if startsWith(line, '#')
            % Check if this looks like a sample header by counting columns
            if contains(line, 'Sample Name') && contains(line, 'Session Name')
                sampleStartIdx = i;
                break;
            end
        else
            % Check if this line matches target format
            values = strsplit(line, '\t');
            if length(values) == length(targetColumns)
                targetDataLines{end+1} = line;
            end
        end
    end
    
    % Parse target data
    targetData = parseDataSection(targetDataLines, targetColumns);
    
    % Find and parse sample data
    if ~isempty(sampleStartIdx)
        sampleHeader = lines{sampleStartIdx};
        sampleColumns = strsplit(sampleHeader(3:end), '\t'); % Remove "# "
        
        % Get sample data lines
        sampleDataLines = {};
        for i = (sampleStartIdx + 1):length(lines)
            line = lines{i};
            if ~isempty(strtrim(line)) && ~startsWith(line, '#')
                values = strsplit(line, '\t');
                if length(values) == length(sampleColumns)
                    sampleDataLines{end+1} = line;
                end
            end
        end
        
        sampleData = parseDataSection(sampleDataLines, sampleColumns);
    end
end

function data = parseDataSection(dataLines, columns)
    % Parse a section of data given the lines and column headers
    
    if isempty(dataLines)
        data = [];
        return;
    end
    
    % Initialize data structure
    data = struct();
    for i = 1:length(columns)
        data.(matlab.lang.makeValidName(columns{i})) = {};
    end
    
    % Parse each data line
    for i = 1:length(dataLines)
        line = dataLines{i};
        values = strsplit(line, '\t');
        
        % Make sure we have the right number of columns
        if length(values) ~= length(columns)
            fprintf('Warning: Line %d has %d values but expected %d columns\n', ...
                i, length(values), length(columns));
            continue;
        end
        
        % Store each value
        for j = 1:length(columns)
            fieldName = matlab.lang.makeValidName(columns{j});
            value = strtrim(values{j});
            
            % Try to convert to number, keep as string if not possible
            numValue = str2double(value);
            if ~isnan(numValue)
                data.(fieldName){end+1} = numValue;
            else
                data.(fieldName){end+1} = value;
            end
        end
    end
    
    % Convert cell arrays to regular arrays where appropriate
    fieldNames = fieldnames(data);
    for i = 1:length(fieldNames)
        field = fieldNames{i};
        if all(cellfun(@(x) isnumeric(x) && ~isnan(x), data.(field)))
            data.(field) = cell2mat(data.(field));
        end
    end
end

%% DEBUG version
function [targetData, sampleData] = parseFlexibleFileDebug(filename)
    % Parse files that can have two different structures with enhanced debugging
    
    % Read the entire file
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file: %s', filename);
    end
    
    % Read all lines
    lines = {};
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            lines{end+1} = line;
        end
    end
    fclose(fid);
    
    % Debug: Print first 50 lines to understand structure
    fprintf('=== FILE STRUCTURE DEBUG ===\n');
    maxLines = min(50, length(lines));
    for i = 1:maxLines
        fprintf('Line %2d: %s\n', i, lines{i});
    end
    fprintf('=== END DEBUG ===\n\n');
    
    % Initialize output structures
    targetData = [];
    sampleData = [];
    
    % Find key header lines with more detailed detection
    targetHeaderIdx = [];
    sampleHeaderIdx = [];
    
    for i = 1:length(lines)
        line = lines{i};
        
        % Look for target header (starts with "# Target Name")
        if startsWith(line, '# Target Name')
            targetHeaderIdx = i;
            fprintf('Found target header at line %d: %s\n', i, line);
        end
        
        % Look for sample header (starts with "# Sample Name")
        if startsWith(line, '# Sample Name')
            sampleHeaderIdx = i;
            fprintf('Found sample header at line %d: %s\n', i, line);
            
            % Debug: Show the header parsing
            sampleColumns = strsplit(line(3:end), '\t');
            fprintf('Sample header has %d columns: %s\n', length(sampleColumns), ...
                strjoin(sampleColumns, ' | '));
        end
    end
    
    % Parse based on which headers we found
    if ~isempty(targetHeaderIdx) && ~isempty(sampleHeaderIdx)
        % Type 2: Both headers present
        fprintf('Detected Type 2 file format\n');
        [targetData, sampleData] = parseType2Debug(lines, targetHeaderIdx, sampleHeaderIdx);
        
    elseif ~isempty(targetHeaderIdx) && isempty(sampleHeaderIdx)
        % Type 1: Only target header, need to find where sample data starts
        fprintf('Detected Type 1 file format\n');
        [targetData, sampleData] = parseType1Debug(lines, targetHeaderIdx);
        
    else
        error('Could not identify file format - no recognizable headers found');
    end
end

function [targetData, sampleData] = parseType2Debug(lines, targetHeaderIdx, sampleHeaderIdx)
    % Parse Type 2 files with debugging
    
    % Parse target header
    targetHeader = lines{targetHeaderIdx};
    targetColumns = strsplit(targetHeader(3:end), '\t');
    
    % Get target data lines (between target header and sample header)
    targetDataLines = {};
    fprintf('\n=== TARGET SECTION ===\n');
    for i = (targetHeaderIdx + 1):(sampleHeaderIdx - 1)
        line = lines{i};
        fprintf('Line %d: "%s"\n', i, line);
        if ~isempty(strtrim(line)) && ~startsWith(line, '#')
            targetDataLines{end+1} = line;
            fprintf('  -> Added as target data\n');
        end
    end
    
    % Parse target data
    targetData = parseDataSectionDebug(targetDataLines, targetColumns, 'TARGET');
    
    % Parse sample header
    sampleHeader = lines{sampleHeaderIdx};
    sampleColumns = strsplit(sampleHeader(3:end), '\t');
    
    % Get sample data lines (after sample header)
    sampleDataLines = {};
    fprintf('\n=== SAMPLE SECTION ===\n');
    fprintf('Sample header: %s\n', sampleHeader);
    fprintf('Expected columns (%d): %s\n', length(sampleColumns), strjoin(sampleColumns, ' | '));
    
    for i = (sampleHeaderIdx + 1):length(lines)
        line = lines{i};
        if ~isempty(strtrim(line)) && ~startsWith(line, '#')
            sampleDataLines{end+1} = line;
            % Debug: show first few sample lines in detail
            if length(sampleDataLines) <= 5
                values = strsplit(line, '\t');
                fprintf('Line %d (%d values): %s\n', i, length(values), line);
                if length(values) ~= length(sampleColumns)
                    fprintf('  ERROR: Expected %d columns but got %d\n', length(sampleColumns), length(values));
                end
            end
        end
    end
    
    % Parse sample data
    sampleData = parseDataSectionDebug(sampleDataLines, sampleColumns, 'SAMPLE');
end

function [targetData, sampleData] = parseType1Debug(lines, targetHeaderIdx)
    % Parse Type 1 files with debugging
    fprintf('Type 1 parsing not implemented in debug version\n');
    targetData = [];
    sampleData = [];
end

function data = parseDataSectionDebug(dataLines, columns, sectionName)
    % Parse a section of data with debugging
    
    fprintf('\n=== PARSING %s DATA ===\n', sectionName);
    fprintf('Expected columns (%d): %s\n', length(columns), strjoin(columns, ' | '));
    fprintf('Data lines to process: %d\n', length(dataLines));
    
    if isempty(dataLines)
        data = [];
        return;
    end
    
    % Initialize data structure
    data = struct();
    for i = 1:length(columns)
        data.(matlab.lang.makeValidName(columns{i})) = {};
    end
    
    % Parse each data line
    for i = 1:length(dataLines)
        line = dataLines{i};
        values = strsplit(line, '\t');
        
        % Make sure we have the right number of columns
        if length(values) ~= length(columns)
            fprintf('Warning: Line %d has %d values but expected %d columns\n', ...
                i, length(values), length(columns));
            fprintf('  Line content: "%s"\n', line);
            fprintf('  Values found: %s\n', strjoin(values, ' | '));
            continue;
        end
        
        % Store each value (only for first few lines to avoid spam)
        if i <= 3
            fprintf('Processing line %d successfully\n', i);
        end
        
        for j = 1:length(columns)
            fieldName = matlab.lang.makeValidName(columns{j});
            value = strtrim(values{j});
            
            % Try to convert to number, keep as string if not possible
            numValue = str2double(value);
            if ~isnan(numValue)
                data.(fieldName){end+1} = numValue;
            else
                data.(fieldName){end+1} = value;
            end
        end
    end
    
    % Convert cell arrays to regular arrays where appropriate
    fieldNames = fieldnames(data);
    for i = 1:length(fieldNames)
        field = fieldNames{i};
        if all(cellfun(@(x) isnumeric(x) && ~isnan(x), data.(field)))
            data.(field) = cell2mat(data.(field));
        end
    end
    
    fprintf('Successfully parsed %d rows for %s section\n', length(dataLines), sectionName);
end
