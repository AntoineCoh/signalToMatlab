for i = 1:length(data.samples)
    plot(data.samples{1, i}.EMG_Data_1)
    hold on
end

%%
EMG_Start = data.samples{1, 25}.EMG_Start;
EMG_End = data.samples{1, 25}.EMG_End;
EMG_Res = data.samples{1, 25}.EMG_Res_; 

Fs = 1000 / EMG_Res;

t = -50:0.3333:150;

figure
plot(t', data.samples{1, 25}.EMG_Data_1)