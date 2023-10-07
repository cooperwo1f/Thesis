clear udp
clear val

udp = dsp.UDPReceiver("LocalIPPort", 3333, "ReceiveBufferSize", 1, "MessageDataType", "uint32");
setup(udp);

val = udp()