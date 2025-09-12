function time = timeDefinition(data)

    %{ Take as argument the data file from Brainsight
    %  and return a vector of time 
    %}

    % Collecte info to plot the MEP
    EMG_Start = data.samples{1, 1}.EMG_Start;   % start time of the signal
    EMG_End = data.samples{1, 1}.EMG_End;       % end time of the signal
    EMG_Res = data.samples{1, 1}.EMG_Res_;      % EMG's resolution
    
    Fs = 1000 / EMG_Res;    % EMG's frequency
    time = EMG_Start:0.3333:EMG_End;     % time vector for plotting