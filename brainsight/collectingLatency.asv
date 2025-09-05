function latencies = collectingLatency(selectedMEP)
%{
    this function takes into arguments the selected MEP
%}
    
    latencies = struct();
    n = length(selectedMEP.samples);

    for i = 1:n
        sampleName = matlab.lang.makeValidName(selectedMEP.samples{1, i}.Sample_Name);
        latencies.(sampleName) = selectedMEP.samples{1,i}.EMG_Latency_1;
    end
end