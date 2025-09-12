function allMEP = mepMatrix(data)
    %{
          Function that takes the data from Brainsight in argument 
            and return a table of all MEPs in columns
    %}

    nMEP = length(data.samples);
    selectedMEPs = {};

    % Create the matrix with all the MEPs 
    allMEP = [] ;

    for i = 1:nMEP
        MEP = data.samples{1,i}.EMG_Data_1 ;
        allMEP = [allMEP, MEP'];
    end
