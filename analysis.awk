#AWK Script to Process Trace File Contents

#BEGIN section begins here
BEGIN {
    #Variable to hold sequence number
    sequenceNo = -1;

    #Counter variable
    Counter = 0;

    #Variable to hold dropped packets
    droppedPackets = 0;

    #Variable to hold received packes
    receivedPackets = 0;

    #Variable to hold received packet size
    receivedSize = 0;

    #Variable to hold start time of simulation
    startTime = 500;

    #Variable to hold end time of sumulation
    stopTime = 0;
}

#Middle section begins here
{
    #Getting sequence number
    #Agent level, Sent Packet, and sequence number
    if($4 == "AGT" && $1 == "s" && seqno < $6)
    {
        sequenceNo = $6;
    }
    #Getting no of received packets
    #Agent level and received packet
    else if($4 == "AGT" && $1 == "r")
    {
        receivedPackets++;
    }
    #Getting no of dropped packets
    #Packet dropped, TCP connection, and size > 512 bytes
    else if($1 == "D" && $7 == "tcp" && $8 > 512)
    {
        droppedPackets++;
    }

    #Getting start time of a packet transfer
    #Agent level and sent packet
    if($4 == "AGT" && $1 == "s")
    {
        start_time[$6] = $2;
    }
    #Getting end time of a packet transfer
    #TCP connection and received packet
    else if($7 == "tcp" && $1 == "r")
    {
        end_time[$6] = $2;
    }
    #Getting end time of a packet transfer
    #TCP connection and dropped packet
    else if($1 == "D" && $7 == "tcp")
    {
        end_time[$6] = -1;
    }

    #Variables to hold column data of a row
    event = $1;
    time = $2;
    node_id = $3;
    packet_size = $8;
    level = $4;

    #Getting start time of network simulation
    #Agent level, sent packet, and size > 512 bytes
    if(level == "AGT" && event == "s" && packet_size >= 512)
    {
        if(time < startTime)
        {
            startTime = time;
        }
    }

    #Getting end time of network simulation
    #Getting received packet size
    #Agent level, received packet, and size > 512
    if(level == "AGT" && event == "r" && packet_size >= 512)
    {
        if(time > stopTime)
        {
            stopTime = time;
        }

        hdr_size = packet_size % 512;
        packet_size -= hdr_size;
        receivedSize += packet_size;
    }
}

#END section begins here
END {
    #Calculating delay for individual packet
    for(i = 0; i <= sequenceNo; i++)
    {
        if(end_time[i] > 0)
        {
            delay[i] = end_time[i] - start_time[i];
            Counter++;
        }
        else
        {
            delay[i] = -1;
        }
    }

    #Calculating ETE delay of network simulation
    for(i = 0; i < sequenceNo; i++)
    {
        if(delay[i] > 0)
        {
            ete_delay += delay[i];
        }
    }
    ete_delay /= Counter;

    #Printing the required results
    print "";
    #print "Start Time               : " startTime "\n";
	#print "Stop Time                : " stopTime "\n";
	#print "Generated Packets        : " sequenceNo + 1 "\n";
	#print "Received Packets         : " receivedPackets "\n";
    #print "Total Dropped Packets    : " droppedPackets "\n";

    #Calculating PDR
	print "Packet Delivery Ratio    : " receivedPackets / (sequenceNo + 1) * 100"%";
	print "End-to-End [ETE] Delay   : " ete_delay * 1000 " ms";
    #Calculating Throughput in Mbps
	print "Throughput [in Mbps]     : " (receivedSize / (stopTime - startTime)) * (8 / 1000000) "\n";
}