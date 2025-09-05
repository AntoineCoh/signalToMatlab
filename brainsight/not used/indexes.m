function indexes = findLines(fileName, numLines)

    fid = fopen(filename, 'r');   % opening the file
    
    indexes = [];
    i = 0

    while ~feof(fid)
        line = fgetl(fid);
        i = i +1;
        if length(line) < 3500
            indexes = [indexes 0];
        else
            indexes = [indexes 1];
        end
    end

        fclose(fid);