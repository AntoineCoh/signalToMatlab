function MEPVariability(S)   

   fieldNames = fieldnames(S);
   n = length(fieldNames);
   
   for i = 1:n
       pk2pk = [];
       nbMEPs = length(S.(fieldNames{i}));
       nbMEPsCol = (1:nbMEPs);
       for j = 1:nbMEPs
           pk2pk = [pk2pk; S.(fieldNames{i}){1,j}.EMG_Peak_to_peak_1];
       end

       meanPk2Pk = mean(pk2pk);
       
       subplot(n, 1, i)
       plot(nbMEPsCol, pk2pk, '-x')
       yline(meanPk2Pk)
       grid on
       grid minor
       title(S.(fieldNames{i}){1,j}.Assoc__Target)
   end