clear server

server = tcpserver("0.0.0.0", 2000);
configureCallback(server, "byte", 4, @server_callback);

function server_callback(src, ~)
    bytes = read(src, src.BytesAvailableFcnCount, "uint8");
    text = char(bytes);
    disp(text)
end
