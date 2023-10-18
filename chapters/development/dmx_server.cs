static void Main(string[] args)
{
       TcpListener server = null;
       OpenDMX open_dmx = new OpenDMX();

       Int32 port = 13000;
       IPAddress localAddr = IPAddress.Parse("127.0.0.1");

       server = new TcpListener(localAddr, port);
       server.Start();

       TcpClient client = server.AcceptTcpClient();
       Console.WriteLine("CLIENT CONNECTED");
       NetworkStream stream = client.GetStream();

       while (!client.Connected) ;

       while (client.Connected)
       {
            int buf_len;
            byte[] buf = new byte[1024];

            if ((buf_len = stream.Read(buf, 0, buf.Length)) > 0)
            {
               string str = Encoding.UTF8.GetString(buf, 0, buf_len).ToString();
               int channel = int.Parse(str.Split(new char[] { '='  })[0]);
               byte value = byte.Parse(str.Split(new char[] { '='  })[1]);
               open_dmx.setDmxValue(channel, value);
            }
       }
}
