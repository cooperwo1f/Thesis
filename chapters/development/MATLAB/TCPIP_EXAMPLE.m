PACKET_LENGTH = 1;
DATA_LENGTH = 1024;

load('./Previous/MatFiles/ex_ecgdata360Hz.mat');
ECG = ecgdata360Hz_hrmean220;
RATE = 1 / 360;

packet_index = 1;
data = zeros(DATA_LENGTH, 1);

while true
    packet_index = packet_index + PACKET_LENGTH;

    %%% bounds check
    if packet_index + PACKET_LENGTH > length(ECG)
        packet_index = 1;
    end

    packet = ECG(packet_index:packet_index + PACKET_LENGTH);

    data(1:end-PACKET_LENGTH) = data(1+PACKET_LENGTH:end);
    data(end-PACKET_LENGTH:end) = packet(1:end);

    [peaks, locations, widths, prominances] = findpeaks(data);
    threshold = max(prominances) * .60;
    ecg_peak_locations = locations(prominances > threshold);

    peak_gap = zeros;
    for i = 2:length(ecg_peak_locations)
        peak_gap(i-1) = ecg_peak_locations(i) - ecg_peak_locations(i-1);
    end

    BPM = round(360 / mean(peak_gap) * 60, 0);
    plot(data)
    axis([0 DATA_LENGTH -2 2]);

    pause(RATE);
end
