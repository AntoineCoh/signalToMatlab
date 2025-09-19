for i = 1:length(data.samples)
    plot(data.samples{1, i}.EMG_Data_1)
    hold on
end

%%
EMG_Start = data.samples{1, i}.EMG_Start;
EMG_End = data.samples{1, i}.EMG_End;
EMG_Res = data.samples{1, i}.EMG_Res_; 

Fs = 1000 / EMG_Res;

t = EMG_Start:0.3333:EMG_End;

figure
for i = 1:length(data.samples)
    plot(t', data.samples{1, i}.EMG_Data_1)
    hold on
end

% plot(t', data.samples{1, i}.EMG_Data_1)