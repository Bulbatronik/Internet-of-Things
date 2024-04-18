# Internet-of-Things




# Challenges
1) Home challenge #1: Sniffing 
Analyse the traffic with wireshark or
with something else
2) Home challenge #2: Node-RED
The goal of this challenge is to generate messages from a CSV 
files to be sent to your own ThingSpeak channel through
Node-Red
Input data is in the file «iot-feeds.csv». It contains the list of messages to be sent to the ThingSpeak channel using MQTT

Node-red application must
■ Read the iot-feeds.csv file
■ For each ONE of the 100 selected messages (those satisfying the 4 digits
person code constraint just said) do:
▪ Send a MQTT message with the field1, field2 and field5 values of the 
message to the ThingSpeak channel
■ Generate a Node-Red chart (with the ui) with the 100 messages with only
the field5 values (title the chart "RSSI")
■ Set the things in a way to send to ThingSpeak 2 messages per minute

channel https://thingspeak.com/channels/1712709

3) Home challenge #3: 
TinyOS + Node-Red + Thingspeak

Goal of the challenge: send data from a mote to 
thingspeak using MQTT
■ Data to send: current status of the three LEDs of 
the mote in three different field.
□ led0 = field0
□ led1 = field1
□ led2 = field2
■ Send one data per minute: please dont’t DDOS 
Thingspeak’s servers


Store your person code
■ Start a periodic timer of 1 minute
■ Every iteration of the timer:
□ do a step of the ternary conversion
□ according to the remainder of the iteration, toggle
the correspondent LED
■ When the ternary conversion is done (quotient = 0), 
stop the time

Cooja/Node-Red steps
■ Create a mote on Cooja
■ Start the serial socket
■ Read from Node-Red the LEDs status
■ Every iteration of the conversion done on the 
mote, send to Thingspeak via MQTT the LEDs 
status
■ Create a three charts for the three fields
■ led0 on 
■ led1 off
■ led2 off
Field0: 1
Field1: 0
Field2: 

4) Home Challenge #4 Simulate a Wireless Sensor Network with TOSSIM
Develop a TinyOS application
□ Simulate the application with TOSSI

Simulate 2 motes talking between 
each others 
□ Mote #1 sends periodic request (REQ) 
messages to mote #2 containing:
■ Message type: REQ
■ An incremental counter
□ The request has periodicity 1000ms

Only on receipt of a request, mote #2 
sends back a reply (RESP) message 
with:
■ Message type: RESP
■ The counter sent by mote #1
■ A value read from the fake sensor
□ Fake sensor is just a module which 
return a random number, you don’t 
need to modify iT

Each message, REQ and RESP, must 
be acknowledged using the TinyOS
built in ACK module
□ Upon receipt of the Xth REQ-ACK
message:
■ Mote #1 stops to send requests
■ The exercise is done!
□ Use the 
module PacketAcknowledgements to 
send the ACK, don’t reimplement it


# Project 
2.1 Project 1. Smart Bracelets
You are requested to design, implement and test a software prototype for a
smart bracelet. The bracelet is worn by a child and her/his parent to keep
track of the child’s position and trigger alerts when a child goes too far. These
bracelets are becoming more and more popular, with some commercially
available prototypes on the market.
The operation of the smart bracelet couple is as follows:
1. Pairing phase: at startup, the parent’s bracelet and the child’s bracelet
broadcast a 20-char random key used to uniquely couple the two devices. The same random key is pre-loaded at production time on the
two devices: upon reception of a random key, a device checks whether
the received random key is equal to the stored one; if yes, it stores the
address of the source device in memory. Then, a special message is
transmitted (in unicast) to the source device to stop the pairing phase
and move to the next step.
2. Operation mode: in this phase, the parent’s bracelet listen for messages on the radio and accepts only messages coming from the child’s
bracelet. The child’s bracelet periodically transmits INFO messages
(one message every 10 seconds), containing the position (X, Y ) of the
child and an estimate of his/her kinematic status (STANDING, WALKING,
RUNNING, FALLING).
3. Alert Mode: upon reception of an INFO message, the parent’s bracelet
reads the content of the message. If the kinematic status is FALLING,
the bracelet sends a FALL alarm, reporting the position (X, Y ) of the
children. If the parent’s bracelet does not receive any message, after
one minute from the last received message, a MISSING alarm is sent
reporting the last position received.
