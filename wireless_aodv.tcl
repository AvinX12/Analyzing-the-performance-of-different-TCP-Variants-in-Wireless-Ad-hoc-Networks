#Setting up the simulation parameters
set val(chan)		Channel/WirelessChannel	;#Channel Type
set val(prop)		Propagation/TwoRayGround	;#Radio Propagation Model
set val(netif)		Phy/WirelessPhy		;#Network Interface Type
set val(mac)		Mac/802_11			;#MAC Type
set val(ifq)		Queue/DropTail/PriQueue	;#Interface Queue Type
set val(ll)		LL				;#Link Layer Type
set val(ant)		Antenna/OmniAntenna		;#Antenna Model
set val(ifqlen)	50				;#Max Packet in IFQ
set val(nn)		10				;#Number of Mobile Nodes
set val(rp)		AODV				;#Routing Protocol
set val(x)		450				;#Topography X Dimension
set val(y)		450				;#Topography Y Dimension
set val(stop)		50.0				;#Simulation End Time

#Initialization
#Create a simulator object
set ns [new Simulator]

#Setup topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)					;#General Operation Director Node

#Open NS and NAM trace files
set tracefile [open aodv_tahoe_5.tr w]
$ns trace-all $tracefile

set namfile [open aodv_tahoe_5.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)

#Open a xgraph file for total bandwidth
set file1 [open aodv_tahoe_5.xg w]

#Defining the 'finish' procedure
proc finish {} {
	global ns tracefile namfile file1
	$ns flush-trace
	close $tracefile
	close $namfile
	exec xgraph aodv_tahoe_5.xg &
	exec nam aodv_tahoe_5.nam &
	exit 0
}

#Defining a 'record' procedure
proc record {} {
	global sink0 sink1 file1
	set ns [Simulator instance]

	set time 0.1
	set nowtime [$ns now]

	set bw0 [$sink0 set bytes_]
	set bw1 [$sink1 set bytes_]
	set bwt [expr $bw0 + $bw1]
	
	puts $file1 "$nowtime [expr $bwt / $time * 8 / 1000000]"

	$sink0 set bytes_ 0
	$sink1 set bytes_ 0
	$ns at [expr $nowtime + $time] "record"
}

#Create wireless channels
set chan [new $val(chan)]

#Setting up mobile nodes parameters
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#Defining the nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]

#Random movement and size of nodes
$n0 random-motion 0
$n1 random-motion 0
$n2 random-motion 0
$n3 random-motion 0
$n4 random-motion 0
$n5 random-motion 0
$n6 random-motion 0
$n7 random-motion 0
$n8 random-motion 0
$n9 random-motion 0

$ns initial_node_pos $n0 20
$ns initial_node_pos $n1 20
$ns initial_node_pos $n2 20
$ns initial_node_pos $n3 20
$ns initial_node_pos $n4 20
$ns initial_node_pos $n5 20
$ns initial_node_pos $n6 20
$ns initial_node_pos $n7 20
$ns initial_node_pos $n8 20
$ns initial_node_pos $n9 20

#Coordinates of the nodes
$n0 set X_ 50
$n0 set Y_ 50
$n0 set Z_ 0.0

$n1 set X_ 150
$n1 set Y_ 50
$n1 set Z_ 0.0

$n2 set X_ 250
$n2 set Y_ 50
$n2 set Z_ 0.0

$n3 set X_ 350
$n3 set Y_ 50
$n3 set Z_ 0.0

$n4 set X_ 50
$n4 set Y_ 350
$n4 set Z_ 0.0

$n5 set X_ 150
$n5 set Y_ 350
$n5 set Z_ 0.0

$n6 set X_ 250
$n6 set Y_ 350
$n6 set Z_ 0.0

$n7 set X_ 350
$n7 set Y_ 350
$n7 set Z_ 0.0

$n8 set X_ 100
$n8 set Y_ 200
$n8 set Z_ 0.0

$n9 set X_ 300
$n9 set Y_ 200
$n9 set Z_ 0.0

#Mobility of the nodes
set val(velocity)	5
$ns at 1.0 "$n0 setdest 350.0 350.0 $val(velocity)"
$ns at 1.0 "$n1 setdest 250.0 350.0 $val(velocity)"
$ns at 1s.0 "$n2 setdest 150.0 350.0 $val(velocity)"
$ns at 1.0 "$n3 setdest 50.0 350.0 $val(velocity)"
$ns at 1.0 "$n4 setdest 350.0 50.0 $val(velocity)"
$ns at 1.0 "$n5 setdest 250.0 50.0 $val(velocity)"
$ns at 1.0 "$n6 setdest 150.0 50.0 $val(velocity)"
$ns at 1.0 "$n7 setdest 50.0 50.0 $val(velocity)"
$ns at 1.0 "$n8 setdest 300.0 200.0 $val(velocity)"
$ns at 1.0 "$n9 setdest 100.0 200.0 $val(velocity)"

#Setting up FTP application over TCP connection
set tcp0 [new Agent/TCP]
set tcp1 [new Agent/TCP]

set sink0 [new Agent/TCPSink]
set sink1 [new Agent/TCPSink]

$ns attach-agent $n0 $tcp0
$ns attach-agent $n3 $tcp1

$ns attach-agent $n7 $sink0
$ns attach-agent $n4 $sink1

$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1

$tcp0 set packetSize_ 1500
$tcp1 set packetSize_ 1500

set ftp0 [new Application/FTP]
set ftp1 [new Application/FTP]

$ftp0 attach-agent $tcp0
$ftp1 attach-agent $tcp1

#Scheduling the simulation
$ns at 0.0 "record"
$ns at 0.5 "$ftp0 start"
$ns at 0.5 "$ftp1 start"
$ns at 45.0 "$ftp0 stop"
$ns at 45.0 "$ftp1 stop"

#Termination of program
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"

#Run the simulation
$ns run
