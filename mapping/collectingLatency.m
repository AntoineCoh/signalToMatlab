function latencies = collectingLatency(selectedMEP)
%{
    this function takes into arguments the selected MEP
%}
    
    latencies = struct();
    n = length(selectedMEP);

    for i = 1:n
        sampleName = matlab.lang.makeValidName(selectedMEP{1, i}.Sample_Name);
        latencies.(sampleName) = selectedMEP{1,i}.EMG_Latency_1;
    end
end