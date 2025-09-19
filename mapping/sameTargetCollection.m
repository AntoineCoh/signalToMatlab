function S = sameTargetCollection(data)

    S = struct();   % Creating a structure
    for i = 1:length(data.samples)

        % Extract the data
        sample = data.samples{1, i};

        % Make a valid name for structures
        fieldName = matlab.lang.makeValidName(sample.Assoc__Target);

        % If field doesn't exist yet, initialize it as an empty struct array
        if ~isfield(S, fieldName)
            S.(fieldName) = struct();
        end

        % Append the struct to the struct array
        sampleName = matlab.lang.makeValidName(sample.Sample_Name);
        S.(fieldName).(sampleName) = sample;
    end

   