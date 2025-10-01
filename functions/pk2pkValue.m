function pk2pk = pk2pkValue(MEP, window)
    
    w_start = window(1);
    w_end = window(2);

    restrictedMEP = MEP(w_start:w_end);

    pk2pk = max(restrictedMEP)-min(restrictedMEP);

end