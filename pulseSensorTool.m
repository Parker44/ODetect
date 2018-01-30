% pulseSensorTool.m
%
% Purpose: reads data files created by serialReader (from the pulse sensor
% amped in arduino), creates plots and analyses data
%
% Instructions: put the datafiles created by serialReader in the same
% directory as this script. Run the script and select the file you want to
% analyze in the file selection box.

close all;

%% User-Selected Options

% analyze individual file or group of files
singleFile = true;

% output limit constants
lowerlimit = 10;
upperlimit = 980;

% fourier transform constants
sampleFreq_Hz = 500; 

%% Produce Data Array
% if singleFile is true, data contains only one cell
originalDir = cd;
if singleFile
    [filename, ~, ~] = uigetfile({'*.txt'}, 'Choose a data file');
    fid = fopen(filename);
    raw = fscanf(fid, '%d');
    data = {raw};
    fclose(fid);
else
    datadir = uigetdir();
    cd(datadir);
    files = dir('*.txt');
    filenames = {files.name};
    data = cell(1,length(filenames));
    for i = 1:length(filenames)
        fid = fopen(filenames{i});
        raw = fscanf(fid, '%d');
        data{i} = raw;
        fclose(fid);
    end
    cd(originalDir);
end

%% Produce Plots
% currently, this step is skippedd when multiple data files are compared
if singleFile
    
    % produce time-domain plot
    figure;
    plot(linspace(1,size(data{1},1),size(data{1},1)),data{1}');
    title('plot of sensor output');

    % produce FFT plot                                           % Sampling Frequency
    Fn = sampleFreq_Hz/2;                                              % Nyquist Frequency
    L = size(data{1},1);                                                % Signal Length (Obviously)
    ft_y = fft(data{1})/L;                                              % Fourier Transform (Normalised)
    Fv = linspace(0, 1, fix(L/2)+1)*Fn;                             % Frequency Vector
    Iv = 1:length(Fv);                                              % Index Vector
    figure;
    plot(Fv, 2*abs(ft_y(Iv)));
    grid;
    xlabel('Frequency (Arbitrary Units)');
    ylabel('Amplitude (Arbitrary Units)');

    % produce signal range histogram
    figure; hist(data{1},40);
    title('histogram of sensor output');
    
    % histogram of periods over which limits were exceeded
    temp = strsplit(num2str(data{1}<lowerlimit)', '0');
    if isempty(temp{1})
        temp = temp(2:end);
    end
    figure; hist(cellfun(@length, temp));
    title('length of periods when lower limit was exceeded');
    temp = strsplit(num2str(data{1}>upperlimit)', '0');
    if isempty(temp{1})
        temp = temp(2:end);
    end
    figure; hist(cellfun(@length, temp));
    title('length of periods when upper limit was exceeded');
end

%% Perform Analysis Metrics
% iterate through datafiles
metricNames = {'portion exceeding upper limit',...
               'portion exceeding lower limit'};
metric = zeros(length(data),length(metricNames));
for i = 1:length(data)
    
    % portions of data exceeding lower and upper limits
    exceedingupper = sum(data{i}>upperlimit)/size(data{i},1);
    exceedinglower = sum(data{i}<lowerlimit)/size(data{i},1);

    disp(['percentage of file ' num2str(i) ' exceeding upper limit: ' num2str(exceedingupper)]);
    disp(['percentage of file ' num2str(i) ' exceeding lower limit: ' num2str(exceedinglower)]);   
    
    % add all information to metric
    metric(i,1) = exceedingupper;
    metric(i,2) = exceedinglower;
end
if ~singleFile
    for i = 1:length(metricNames)
        [minval, minindex] = min(metric(:,i));
        disp(['file ' num2str(minindex) ' has the minimum ' metricNames{i} ': ' num2str(minval)]);
        [maxval, maxindex] = max(metric(:,i));
        disp(['file ' num2str(maxindex) ' has the maximum ' metricNames{i} ': ' num2str(maxval)]);
    end
end
        

