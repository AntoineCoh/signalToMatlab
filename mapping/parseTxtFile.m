function parsedData = parseTxtFile(file_path)
    % Parse a TXT file containing multiple types of data sections.
    %
    % Args:
    %     file_path (string): Path to the TXT file
    %
    % Returns:
    %     struct containing fields: samples, targets, planned_landmarks, session_landmarks
    
    % Initialize result structure
    parsedData = struct();
    parsedData.samples = {};
    parsedData.targets = {};
    parsedData.planned_landmarks = {};
    parsedData.session_landmarks = {};
    parsedData.session_data = {};
    
    % Define expected headers for each data type
    headers = struct();
    headers.target = {"Target Name", "Loc. X", "Loc. Y", "Loc. Z", "m0n0", "m0n1", "m0n2", "m1n0", "m1n1", "m1n2", "m2n0", "m2n1", "m2n2"};
    headers.sample = {"Sample Name", "Session Name", "Index", "Assoc. Target", "Loc. X", "Loc. Y", "Loc. Z", "m0n0", "m0n1", "m0n2", "m1n0", "m1n1", "m1n2", "m2n0", "m2n1", "m2n2", "Dist. to Target", "Target Error", "Angular Error", "Twist Error", "Stim. Power A", "Stim. Pulse Interval", "Stim. Power B", "Date", "Time", "Creation Cause", "Crosshairs Driver", "Offset", "Comment", "EMG Start", "EMG End", "EMG Res.", "EMG Channels", "EMG Window Start", "EMG Window End", "EMG Peak-to-peak 1", "EMG Latency 1", "EMG Data 1"};
    headers.planned_landmark = {"Planned Landmark Name", "Loc. X", "Loc. Y", "Loc. Z"};
    headers.session_landmark = {"Session Landmark Name", "Session Name", "Used?", "Loc. X", "Loc. Y", "Loc. Z"};
    headers.session_data = {"Session Name", "Loc. X", "Loc. Y", "Loc. Z", "m0n0", "m0n1", "m0n2", "m1n0", "m1n1", "m1n2", "m2n0", "m2n1", "m2n2"};
    
    current_mode = '';
    current_headers = {};
    
    try
        fid = fopen(file_path, 'r', 'n', 'UTF-8');
        if fid == -1
            error('Could not open file: %s', file_path);
        end
        
        line_num = 0;
        while ~feof(fid)
            line = fgetl(fid);
            line_num = line_num + 1;
            
            % Skip empty lines
            if isempty(strtrim(line))
                continue;
            end
            
            line = strtrim(line);
            
            % Check if line is a header
            if startsWith(line, '#')
                if contains(line, 'Target Name')
                    current_mode = 'target';
                    current_headers = headers.target;
                elseif contains(line, 'Sample Name')
                    current_mode = 'sample';
                    current_headers = headers.sample;
                elseif contains(line, 'Planned Landmark Name')
                    current_mode = 'planned_landmark';
                    current_headers = headers.planned_landmark;
                elseif contains(line, 'Session Landmark Name')
                    current_mode = 'session_landmark';
                    current_headers = headers.session_landmark;
                elseif contains(line, 'Session Name') && ~contains(line, 'Session Landmark Name')
                    % This handles the "# Session Name	Loc. X	Loc. Y..." header
                    current_mode = 'session_data';
                    current_headers = headers.session_data;
                else
                    % Skip other comment lines
                    continue;
                end
                continue;
            end
            
            % Parse data lines
            if ~isempty(current_mode)
                try
                    fields = split(line, sprintf('\t'));
                    
                    % Parse the data
                    if ~isempty(current_headers) && length(fields) >= 1
                        data_record = struct();
                        
                        for i = 1:length(current_headers)
                            header = current_headers{i};
                            if i <= length(fields)
                                value = fields{i};
                                if strcmp(current_mode, 'sample') && strcmp(header, 'EMG Data 1') && ~isempty(value) && ~strcmp(value, '(null)')
                                    % Parse semicolon-separated EMG data
                                    data_record.(matlab_field_name(header)) = parse_emg_data(value);
                                else
                                    data_record.(matlab_field_name(header)) = parse_value(value);
                                end
                            else
                                data_record.(matlab_field_name(header)) = [];
                            end
                        end
                        
                        % Add to appropriate list
                        switch current_mode
                            case 'target'
                                parsedData.targets{end+1} = data_record;
                            case 'sample'
                                parsedData.samples{end+1} = data_record;
                            case 'planned_landmark'
                                parsedData.planned_landmarks{end+1} = data_record;
                            case 'session_landmark'
                                parsedData.session_landmarks{end+1} = data_record;
                            case 'session_data'
                                parsedData.session_data{end+1} = data_record;
                        end
                    else
                        fprintf('Warning: Line %d has insufficient data or no headers defined\n', line_num);
                    end
                    
                catch ME
                    fprintf('Error parsing line %d: %s\n', line_num, ME.message);
                    fprintf('Line content: %s\n', line);
                end
            end
        end
        
        fclose(fid);
        
    catch ME
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        fprintf('Error reading file: %s\n', ME.message);
    end
end

function valid_name = matlab_field_name(name)
    % Convert a string to a valid MATLAB field name
    valid_name = regexprep(name, '[^a-zA-Z0-9_]', '_');
    valid_name = regexprep(valid_name, '^([0-9])', 'f$1'); % Can't start with number
    if isempty(valid_name)
        valid_name = 'field';
    end
end

function parsed_value = parse_value(value)
    % Parse a string value to appropriate type (double or string)
    % Handles (null) values
    
    if isempty(value) || strcmp(strtrim(value), '(null)')
        parsed_value = [];
        return;
    end
    
    value = strtrim(value);
    
    % Try to parse as number
    num_value = str2double(value);
    if ~isnan(num_value)
        parsed_value = num_value;
    else
        parsed_value = value; % Return as string
    end
end

function emg_values = parse_emg_data(emg_string)
    % Parse semicolon-separated EMG data string into array of doubles
    
    if isempty(emg_string) || strcmp(strtrim(emg_string), '(null)')
        emg_values = [];
        return;
    end
    
    % Remove trailing "..." if present
    emg_string = regexprep(emg_string, '\.\.\.+$', '');
    
    % Split by semicolon
    parts = split(emg_string, ';');
    emg_values = [];
    
    for i = 1:length(parts)
        part = strtrim(parts{i});
        if ~isempty(part)
            num_val = str2double(part);
            if ~isnan(num_val)
                emg_values(end+1) = num_val;
            else
                fprintf('Warning: Could not parse EMG value: %s\n', part);
            end
        end
    end
end

function print_summary(data)
    % Print a summary of the parsed data
    
    fprintf('Parsed data summary:\n');
    fprintf('- Targets: %d records\n', length(data.targets));
    fprintf('- Samples: %d records\n', length(data.samples));
    fprintf('- Planned Landmarks: %d records\n', length(data.planned_landmarks));
    fprintf('- Session Landmarks: %d records\n', length(data.session_landmarks));
    fprintf('- Session Data: %d records\n', length(data.session_data));
    
    % Show structure of each data type
    data_types = {'targets', 'samples', 'planned_landmarks', 'session_landmarks', 'session_data'};
    
    for i = 1:length(data_types)
        data_type = data_types{i};
        records = data.(data_type);
        
        if ~isempty(records)
            fprintf('\n%s structure:\n', strrep(data_type, '_', ' '));
            field_names = fieldnames(records{1});
            fprintf('  Fields: %s\n', strjoin(field_names, ', '));
            
            % Show EMG data info for samples
            if strcmp(data_type, 'samples') && isfield(records{1}, 'EMG_Data_1')
                emg_data = records{1}.EMG_Data_1;
                if ~isempty(emg_data)
                    fprintf('  EMG Data 1: %d values (first 3: [%.2f, %.2f, %.2f])\n', ...
                        length(emg_data), emg_data(1), emg_data(2), emg_data(3));
                end
            end
        end
    end
end

function save_to_mat_file(data, filename)
    % Save parsed data to .mat file
    if nargin < 2
        filename = 'parsed_data.mat';
    end
    
    save(filename, 'data');
    fprintf('Data saved to %s\n', filename);
end

% Example usage function
function example_usage()
    % Example of how to use the parser
    
    % Replace 'your_file.txt' with the actual path to your file
    file_path = 'your_file.txt';
    
    % Parse the file
    parsed_data = parseTxtFile(file_path);
    
    % Print summary
    print_summary(parsed_data);
    
    % Access different types of data
    targets = parsed_data.targets;
    samples = parsed_data.samples;
    landmarks = parsed_data.planned_landmarks;
    session_landmarks = parsed_data.session_landmarks;
    session_data = parsed_data.session_data;
    
    % Example: Print first record of each type (if available)
    if ~isempty(targets)
        target1 = targets{1};
        fprintf('\nFirst target: %s at (%.2f, %.2f, %.2f)\n', ...
            target1.Target_Name, target1.Loc__X, target1.Loc__Y, target1.Loc__Z);
    end
    
    if ~isempty(samples)
        sample1 = samples{1};
        fprintf('\nFirst sample: %s from %s\n', sample1.Sample_Name, sample1.Session_Name);
        if isfield(sample1, 'EMG_Data_1') && ~isempty(sample1.EMG_Data_1)
            fprintf('  EMG data points: %d\n', length(sample1.EMG_Data_1));
            fprintf('  First 5 EMG values: [%.2f, %.2f, %.2f, %.2f, %.2f]\n', sample1.EMG_Data_1(1:5));
        end
    end
    
    if ~isempty(landmarks)
        landmark1 = landmarks{1};
        fprintf('\nFirst planned landmark: %s at (%.2f, %.2f, %.2f)\n', ...
            landmark1.Planned_Landmark_Name, landmark1.Loc__X, landmark1.Loc__Y, landmark1.Loc__Z);
    end
    
    if ~isempty(session_landmarks)
        landmark1 = session_landmarks{1};
        fprintf('\nFirst session landmark: %s from %s (Used: %s) at (%.2f, %.2f, %.2f)\n', ...
            landmark1.Session_Landmark_Name, landmark1.Session_Name, landmark1.Used_, ...
            landmark1.Loc__X, landmark1.Loc__Y, landmark1.Loc__Z);
    end
    
    if ~isempty(session_data)
        session1 = session_data{1};
        fprintf('\nFirst session data: %s at (%.2f, %.2f, %.2f)\n', ...
            session1.Session_Name, session1.Loc__X, session1.Loc__Y, session1.Loc__Z);
    end
    
    % Save to .mat file
    save_to_mat_file(parsed_data);
end