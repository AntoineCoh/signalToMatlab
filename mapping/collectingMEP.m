function MEPSignal = collectingMEP(selectedMEP)
%{
    this function takes into arguments the selected MEP
%}
    
    MEPSignal = struct();
    n = length(selectedMEP);

    for i = 1:n
        sampleName = matlab.lang.makeValidName(selectedMEP{1, i}.Sample_Name);
        MEPSignal.(sampleName) = selectedMEP{1, i}.EMG_Data_1  ;
    end
end