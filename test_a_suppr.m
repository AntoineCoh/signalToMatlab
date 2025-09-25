figure
for i = 1:length(sampleData.SampleName)
    splitDat = strsplit(sampleData.EMGData1{i}, ';');
    EMG = cellfun(@str2double,splitDat);
    plot(EMG)
    hold on
end