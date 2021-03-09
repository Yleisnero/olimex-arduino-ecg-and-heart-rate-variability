function data = readData(path)
    % Read ecg values and timestamps from file to array
    file = fopen(path, 'r');
    formatSpec = '%f %f';
    sizeA = [2,Inf];
    d = fscanf(file, formatSpec, sizeA);
    fclose(file);
    data = d';
end
