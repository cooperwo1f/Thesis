%% System Setup
clear all %#ok<CLALL>

PACKET_LENGTH = 1;
DATA_LENGTH = 512;

%% Server Setup
server = tcpserver("0.0.0.0", 2000);
configureCallback(server, 'byte', PACKET_LENGTH, @server_callback);

%% Main Loop
hMsgBox = msgbox('Press OK to Stop Server', 'CTRL', 'non-modal');
data = zeros(DATA_LENGTH, 1);
% end byte of UserData is used as new data available flag
server.UserData = zeros(PACKET_LENGTH+1, 1);

plot(data)
axis([0 DATA_LENGTH 0 255]);

while true
    if server.UserData(end) == true
        data(1:end-PACKET_LENGTH) = data(1+PACKET_LENGTH:end);
        data(end-PACKET_LENGTH+1:end) = server.UserData(1:end-1);

        plot(data)
        axis([0 DATA_LENGTH 0 255]);
        
        server.UserData(end) = false;
    end

    if ~ishandle(hMsgBox)
        % Stop the if cancel button was pressed
        disp('Stopped by user');
        break;
    end

    % need to pause to allow function callback to execute
    pause(0.001);
end

close all
clear server

%% Function Defs
function server_callback(src, ~)
    src.UserData = transpose(read(src, src.BytesAvailableFcnCount, "uint8"));
    src.UserData(end+1) = true;
end