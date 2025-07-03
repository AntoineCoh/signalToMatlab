function headersList = findHeaders(filetxt, N)
    for i = 1:N
        line = fgetl(filetxt);
    end
    line = strtrim(erase(line, '#'));
    headersList = strsplit(line, '\t');
end