function MEPSignal = namingMEP(MEPMatrix, selectedIdx)
%{
    this function takes into arguments the selected MEP
    and returns a stucture for each MEP with a name
%}
    
    MEPSignal = struct();
    n = size(MEPMatrix,2);

    for i = 1:n
        sampleName = "MEP_" + num2str(selectedIdx(i));
        MEPSignal.(sampleName) = MEPMatrix(:, i);
    end
end