clear t
t = tcpclient('localhost', 13000);

write(t, "0=10");
write(t, "1=0");
write(t, "2=0");
write(t, "3=0");
write(t, "4=10");
write(t, "5=255");
write(t, "6=0");
write(t, "7=0");
write(t, "8=10");
write(t, "9=0");
write(t, "10=255");
write(t, "11=0");
write(t, "12=10");
write(t, "13=0");
write(t, "14=0");
write(t, "15=255");
write(t, "16=10");
write(t, "17=255");
write(t, "18=255");
write(t, "19=0");
write(t, "20=10");
write(t, "21=0");
write(t, "22=255");
write(t, "23=255");
write(t, "24=10");
write(t, "25=255");
write(t, "26=0");
write(t, "27=255");
write(t, "28=10");
write(t, "29=255");
write(t, "30=255");
write(t, "31=255");


PACKET_LENGTH = 1;
DATA_LENGTH = 1024;
STRLEN = 24+2;

load('./Previous/MatFiles/ex_ecgdata360Hz.mat');
ecg = ecgdata360Hz_hrmean45;
rate = 1 / 360;

[peaks, locations, widths, prominances] = findpeaks(ecg);
threshold = max(prominances) * .60;
ecg_peak_locations = locations(prominances > threshold);

peak_gap = zeros;
for i = 2:length(ecg_peak_locations)
    peak_gap(i-1) = ecg_peak_locations(i) - ecg_peak_locations(i-1);
end

BPM = round(360 / mean(peak_gap) * 60, 0);
disp(BPM)
plot(ecg)