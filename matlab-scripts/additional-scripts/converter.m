% Convert values from arduino to millivolt
filename = '.txt';

data = readData(filename);
time = data(:,1);
ecgValues = data(:,2);

gain = 2848;

ecgValues = ecgValues / gain;

newData = cat(2, time, ecgValues);

filenameWithoutExtension = split(filename, '.');
newFilename = string(strcat('new_', filenameWithoutExtension(1)));
writematrix(newData, newFilename, 'Delimiter', ' ');