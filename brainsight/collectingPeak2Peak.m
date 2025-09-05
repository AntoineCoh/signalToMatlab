function pk2pk = collectingPeak2Peak(selectedMEP)
%{
    this function takes into arguments the selected MEP
%}
    
    pk2pk = struct();
    n = length(selectedMEP);

    for i = 1:n
        sampleName = matlab.lang.makeValidName(selectedMEP{1, i}.Sample_Name);
        pk2pk.(sampleName) = selectedMEP{1, i}.EMG_Peak_to_peak_1  ;
    end
end