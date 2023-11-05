#include "sendAck.h"
#include "Timer.h"

module sendAckC {

  uses {
	interface Boot; 
	interface Packet;
	interface AMPacket;//
	interface PacketAcknowledgements;
	interface AMSend;
	interface SplitControl;// to turn onn
	interface Receive;// to RX
	interface Timer<TMilli> as MilliTimer;
	interface Read<uint16_t>;// to perform sensor reading
  }

} implementation {
  
  
  uint8_t last_digit = 2;//X-1
  
  uint8_t counter = 0;//two counters for both motes
  uint8_t rec_id;
  
  uint8_t req_ack = 0;// counter for REQ-ACK
  
  message_t packet;

  void sendReq();
  void sendResp();
  
  //***************** Send request function ********************//
  void sendReq() {
  	/* This function is called when we want to send a request
	 *
	 * STEPS:
	 * 1. Prepare the msg
	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)
	 * 3. Send an UNICAST message to the correct node
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 
	 //1. Prepare the msg
	 my_msg_t* req = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
	 
	 counter++;
	 req->msg_type = REQ;
     req->msg_counter = counter;
	 
	
    dbg("radio_send", "I am trying to send a REQUEST to node 2 at %s \n", sim_time_string());
    
    //2. Set the ACK flag for the message using the PacketAcknowledgements interface
    call PacketAcknowledgements.requestAck(&packet);//must be ACKed 
    
    //3. Send an UNICAST message to the correct node  
    if (call AMSend.send(2, &packet, sizeof(my_msg_t)) == SUCCESS) {//to the node 2
		
		dbg("radio_send", "Trying to send REQ\n");	
      	dbg_clear("radio_pack","Payload:" );
      	dbg_clear("radio_pack", "\t msg_type: %hhu", req->msg_type);
      	dbg_clear("radio_pack", "\t msg_counter: %hhu \n", req->msg_counter);
      	dbg_clear("radio_send", "\n");
      }
 }//THEN SEND DONE        
  
  //****************** Task send response *****************//
  void sendResp() {
	call Read.read();;//measurement of the sensor
  }//THEN READ DONE
  
  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application is booted.\n");
    call SplitControl.start();
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
  
    if (err == SUCCESS) {//successfull start
    
      dbg("radio","Radio is on\n");
      
      if (TOS_NODE_ID == 1){//sensor one sends
    		dbg("role","Mote 1 starts sending REQ\n");
      		call MilliTimer.startPeriodic(1000);//node 1 will transmit
    	}
    }
    else {
      	call SplitControl.start();
        }
  }
  
  event void SplitControl.stopDone(error_t err){
    dbg("boot", "Radio stopped!\n");
  }

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	 sendReq();
  }
  
  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
	 /* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer according to your id. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 
	 //1. Check if the packet is sent
	 if (&packet == buf && err == SUCCESS) {
      dbg("radio_send", "Packet is sent\n");
      	
      	//2. Check if the ACK is received
      	if (call PacketAcknowledgements.wasAcked(buf)){
      		 dbg_clear("radio_ack", "ACK is received at time %s \n", sim_time_string());
      		 
      		 if (TOS_NODE_ID == 1){
      		 	req_ack++;
      		 	dbg("radio_rec", "---------REQ-ACK #%hhu -------------\n\n", req_ack);
      		    
      		    //2a. If yes, stop the timer according to your id. The program is done
      		    if (req_ack == last_digit + 1){
      		    	call MilliTimer.stop();
      		    	}
      		    
      		 }
      	}else{
      	
      	 //2b. Otherwise, send again the request
      	 dbg_clear("radio_ack", "ACK is NOT received\n");
      	 return;
      	 //call MilliTimer.startPeriodic(1000);//Retrying 1 sec later
      	}
     }
  }
  
  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
    /* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 	
	 	//1. Read the content of the message
		my_msg_t* msg = (my_msg_t*)payload;
		rec_id = msg->msg_counter;
		
		dbg("radio_rec", "Message received at time %s \n", sim_time_string());
		dbg_clear("radio_pack","Payload:" );
      	dbg_clear("radio_pack", "\t msg_type: %hhu", msg->msg_type);
      	dbg_clear("radio_pack", "\t msg_counter: %hhu", msg->msg_counter);
      	if (msg->msg_type == RESP){
      		dbg_clear("radio_pack", "\t msg_value: %hhu\n", msg->value);
      	}else{
      		dbg_clear("radio_pack","\n");
      	}
      	dbg_clear("radio_rec", "\n");
		
		//2. Check if the type is request (REQ)
		if (msg->msg_type == REQ){//ONLY NODE 2
		
			//3. If a request is received, send the response
	 		sendResp();
		}
	return buf;
  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {
    /* This event is triggered when the fake sensor finishes to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
	 
	 //1. Prepare the response (RESP)
	 my_msg_t* resp = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
	 
	 resp->msg_type = RESP;
	 resp->msg_counter = rec_id;
	 resp->value = data;

     dbg("radio_send", "I am trying to send a RESPONSE to node 1 at %s \n", sim_time_string());	
		      
    call PacketAcknowledgements.requestAck(&packet); // We need ack
    
    //2. Send back (with a unicast message) the response
    if (call AMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS) {//to the node 1
		dbg("radio_send", "Trying to send RESP\n");	
      	dbg_clear("radio_pack","Payload:" );
      	dbg_clear("radio_pack", "\t msg_type: %hhu", resp->msg_type);
      	dbg_clear("radio_pack", "\t msg_counter: %hhu", resp->msg_counter);
      	dbg_clear("radio_pack", "\t msg_value: %hhu\n", resp->value);
      	dbg_clear("radio_rec", "\n");
     }
  }//THEN SEND DONE
	  
}

