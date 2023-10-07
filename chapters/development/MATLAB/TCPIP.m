clear server

server = tcpserver("0.0.0.0", 2000);
configureTerminator(server, "LF");
configureCallback(server, "terminator", @server_callback);

function server_callback(src, ~)
    base64 = readline(src);
    decoded = matlab.net.base64decode(char(base64));
    bytes = uint8(transpose(decoded));
end
