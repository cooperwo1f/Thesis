%% Sys Setup

PACKET_LENGTH = 1;
DATA_LENGTH = 1024;

load('./Previous/MatFiles/ex_ecgdata360Hz.mat');
ECG = ecgdata360Hz_hrmean220;
RATE = 1 / 360;

hMsgBox = msgbox('Press OK to Stop', 'CTRL', 'non-modal');
packet_index = 1;
data = zeros(DATA_LENGTH, 1);

t = tcpclient('localhost', 13000);
write(t, "1=255");
write(t, "2=255");
write(t, "3=255");

written = false;

while true
    packet_index = packet_index + PACKET_LENGTH;

    %%% bounds check
    if packet_index + PACKET_LENGTH > length(ECG)
        packet_index = 1;
    end

    packet = ECG(packet_index:packet_index + PACKET_LENGTH);

    data(1:end-PACKET_LENGTH) = data(1+PACKET_LENGTH:end);
    data(end-PACKET_LENGTH:end) = packet(1:end);

    plot(data)
    axis([0 DATA_LENGTH -2 2]);

    %%% server side signal analaysis
    [peaks, locations, widths, prominances] = findpeaks(data);
    threshold = max(prominances) * .60;
    ecg_peak_locations = locations(prominances > threshold);

    if (ecg_peak_locations(end) > (DATA_LENGTH * 0.98))
        write(t, "0=10");
    else
        write(t, "0=0")
    end

    % Currently write and read are taking far too long
    % Possibly put on own thread or try and find async versions
    % Might only be an issue with read waiting for data
    % Try and find out a way to not have the data incoming potentially, 
    % for some reason Arduino halts if serialport is not read...

    peak_gap = zeros;
    for i = 2:length(ecg_peak_locations)
        peak_gap(i-1) = ecg_peak_locations(i) - ecg_peak_locations(i-1);
    end

    BPM = round(360 / mean(peak_gap) * 60, 0);
    %plot(data)

    % Would be cool to align the most recent peak so we can do other stuff
    % on the off peaks since we also know the BPM
    % For example flashing secondary LEDs based on the 2nd, 3rd, 4th, etc 
    % beat of a set time signature

    %%% loop stop handler
    if ~ishandle(hMsgBox)
        % Stop the if cancel button was pressed
        disp('Stopped by user');
        break;
    end

    %%% loop delay (allows for callback function)
    pause(RATE);
end

clear t
close all
