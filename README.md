<h1 align="center">Internet Of Things</h1>


<p align="center">
  <a href="#dart-about">About</a> &#xa0; | &#xa0; 
  <a href="#rocket-technologies">Technologies</a> &#xa0; | &#xa0;
  <a href="#checkered_flag-starting">Starting</a> &#xa0; | &#xa0;
  <a href="#memo-license">License</a> &#xa0; | &#xa0;
  </p>
<br>

## :dart: About ##

Welcome to the Internet of Things project repository! This repository contains two main folders:


### [Project: Smart Bracelets](Project)


a software prototype for a smart bracelet. The bracelet is worn by a child and her/his parent to keep track of the child’s position and trigger alerts when a child goes too far. These
bracelets are becoming more and more popular, with some commercially available prototypes on the market.
The operation of the smart bracelet couple is as follows:
1. Pairing phase: at startup, the parent’s bracelet and the child’s bracelet broadcast a 20-char random key used to uniquely couple the two devices. The same random key is pre-loaded at production time on the two devices: upon reception of a random key, a device checks whether the received random key is equal to the stored one; if yes, it stores the address of the source device in memory. Then, a special message is transmitted (in unicast) to the source device to stop the pairing phase and move to the next step.
2. Operation mode: in this phase, the parent’s bracelet listen for messages on the radio and accepts only messages coming from the child’s bracelet. The child’s bracelet periodically transmits INFO messages (one message every 10 seconds), containing the position (X, Y) of the child and an estimate of his/her kinematic status (STANDING, WALKING, RUNNING, FALLING).
3. Alert Mode: upon reception of an INFO message, the parent’s bracelet reads the content of the message. If the kinematic status is FALLING, the bracelet sends a FALL alarm, reporting the position (X, Y) of the children. If the parent’s bracelet does not receive any message, after one minute from the last received message, a MISSING alarm is sent reporting the last position received.


### [Challenges](Challenges)

This folder contains challenges related to Internet of Things.

1. **Home challenge #1: [Sniffing](Challenges/challenge1/)**
   - Analyze the traffic with Wireshark or any other tool.

2. **Home challenge #2: [Node-RED](Challenges/challenge2/)**
   - Goal: Generate messages from a CSV file to be sent to your ThingSpeak channel through Node-RED.
   - Input data: `iot-feeds.csv`.
   - Node-RED application requirements detailed in the challenge description.
   - ThingSpeak channel: [Link](https://thingspeak.com/channels/1712709).

3. **Home challenge #3: [TinyOS + Node-Red + ThingSpeak](Challenges/challenge3/)**
   - Goal: Send data from a mote to ThingSpeak using MQTT.
   - Detailed requirements provided in the challenge description.

4. **Home Challenge #4: [Simulate a Wireless Sensor Network with TOSSIM](Challenges/challenge4/)**
   - Develop a TinyOS application to simulate a wireless sensor network with TOSSIM.
   - Detailed requirements provided in the challenge description.

## Technologies ##

The following tools were used in this project:

- [Node-Red](https://flows.nodered.org/)
- [Tiny-OS](https://github.com/tinyos/tinyos-main/tree/master)
- [Wireshark](https://www.wireshark.org/)
- [Coja](https://www.phddirection.com/cooja-simulator-for-iot/)

##  Starting ##

```bash
# Clone this project
$ git clone https://github.com/Bulbatronik/Internet-of-Things.git

# Access
$ cd internet-of-things
```

## License ##

This project is under license from MIT. For more details, see the [LICENSE](LICENSE.md) file.

