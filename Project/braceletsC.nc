#include "bracelets.h"
#include "Timer.h"
#include <stdio.h>
#include "printf.h"	

#define formatBool(b) ((b) ? "true" : "false")

//make telosb
module braceletsC {

  uses {
	interface Boot; 
	interface Packet;
	interface AMPacket;
	interface AMSend;
	interface PacketAcknowledgements;
	interface SplitControl;
	interface Receive;
	interface Random;
	
	interface Timer<TMilli> as TimerPairing;
	interface Timer<TMilli> as TimerOperation;
	interface Timer<TMilli> as TimerMissing;
  }

} implementation {
   
  bool busy = FALSE;
  
  char key_stored[2][21] = {"BF6tb8n98uJO68dBD2d3", 
  							"AJnk2819yBSAMOWheeeO"};//codes for two pairs. Add more codes for more pairs
  bool paired = FALSE;
  
  
  uint8_t received;  
  uint16_t rnd;
  uint16_t X_last, Y_last;
  
  
  message_t packet;
  
  am_addr_t address_coupled_device;//to save the address
  
  void sendKey();
  void respKey(); 
  void sendINFO();
  void fallAlarm(uint16_t, uint16_t);
  void missingAlarm(); 
  
  //***************** Send request function ********************//
  void sendKey() {
	 key_msg_t* key_req = (key_msg_t*)call Packet.getPayload(&packet, sizeof(key_msg_t));
	 
	 strcpy(key_req->key, key_stored[TOS_NODE_ID/2]);//nodes 1, 3, 5... -> indexes 0,1,2,...
	 
	 printf("Creatng a packet to be sent\n");
	 call PacketAcknowledgements.requestAck(&packet);
	
     if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(key_msg_t)) == SUCCESS) {//to the node 2
		printf("Trying to pair\n");
      	printf("Payload\n");
      	printf("Key: %s\n", key_req->key);
      }
      printfflush();
 }//THEN SEND DONE        
  
  //****************** Task send response *****************//
  void respKey() {
	 key_msg_t* resp = (key_msg_t*)call Packet.getPayload(&packet, sizeof(key_msg_t));
	 
	 resp->state = OK;
	
	 printf("I am trying to send a RESPONSE to parent (Unicast) \n");
	 call PacketAcknowledgements.requestAck(&packet);
	 
     if (call AMSend.send(address_coupled_device, &packet, sizeof(key_msg_t)) == SUCCESS) {
		printf("Node %d has sent send RESP to node %d\n", TOS_NODE_ID, address_coupled_device);
		call TimerOperation.startPeriodic(10000);	
     }
     printfflush();
  }//THEN SEND DONE
  
  
  void sendINFO() {
	 info_msg_t* info_msg = (info_msg_t*)call Packet.getPayload(&packet, sizeof(info_msg_t));
	
	 info_msg->X = call Random.rand16();
	 info_msg->Y = call Random.rand16();
	 
	 rnd = (call Random.rand16() % 10) + 1; // rand from [1,10]
	 if(rnd>=1 && rnd<=3){
			info_msg->status = STANDING;
		}else if(rnd>=4 && rnd<=6){
			info_msg->status = WALKING;
		}else if(rnd>=7 && rnd<=9){
			info_msg->status = RUNNING;
		}else if(rnd==10){
			info_msg->status = FALLING;
		}
	 
	 printf("Creatng a child's data\n");
	 
	 call PacketAcknowledgements.requestAck(&packet);
	 
	 printf("Node %d is trying to send INFO to node %d\n", TOS_NODE_ID, address_coupled_device);
    
     if (call AMSend.send(address_coupled_device, &packet, sizeof(info_msg_t)) == SUCCESS) {
		printf("Payload\n");
      	printf("X: %d\n", info_msg->X);
  		printf("Y: %d\n", info_msg->Y);
      	printf("Status: %d\n", info_msg->status);
      }
      printfflush();
      
 }
        
  void fallAlarm(uint16_t X, uint16_t Y){
  		printf("THE CHILD HAS FALLEN. COORDINATES:\n");
  		printf("X: %d; Y: %d\n", X, Y);
  		printf("HELP IS NEEDED!!!\n");
  		printfflush();
  } 
  
  void missingAlarm(){
  		printf("THE CHILD IS MISSIMG. LAST COORDINATES RECEIVED:\n");
  		printf("X: %d; Y: %d\n", X_last, Y_last);
  		printf("WHERE IS BILLY?!?!\n");
  		printfflush();
  } 
  //***************** Boot interface ********************//
  event void Boot.booted() {
  	printf("Application is running!\n");
  	printfflush();
	
    call SplitControl.start();
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
  
    if (err == SUCCESS) {//successfull start
      printf("Radio is on\n");
      
      if (TOS_NODE_ID %2 == 1){//ODD SENSORS ARE PARENTS
      		printf("Parent starts sending pairing message\n");
      		printfflush();
      		call TimerPairing.startPeriodic(5000);//node 1 will transmit
    	}
    }
    else {
      	call SplitControl.start();
        }
  }
  
  event void SplitControl.stopDone(error_t err){
  	printf("Radio is stopped!\n");
    printfflush();
  }

  //***************** MilliTimer interface ********************//
  event void TimerPairing.fired() {//part 1
	 sendKey();
  }
  
  event void TimerOperation.fired() {
	 sendINFO();
  }
  
  event void TimerMissing.fired() {
	 missingAlarm();
  }
  
  
   //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf, error_t err) {
	 if (&packet == buf && err == SUCCESS ) {
	 	printf("Packet is sent\n");
	 	
	 	printf("Was it broadcasted? %s\n",formatBool(call AMPacket.destination( buf ) == AM_BROADCAST_ADDR));
			
	 	if (call PacketAcknowledgements.wasAcked(buf)){
      		 printf("ACK is received\n");
      		 printfflush();  
      	}else{
      	 	printf("ACK is NOT received\n");
      	 	printfflush(); 
      	 	return;
            }	 	
     }
  }
  
  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
 	 	if (TOS_NODE_ID %2 == 0 && paired == FALSE){//Child receives something, phase 1
 	 		
 			key_msg_t* msg = (key_msg_t*)payload;
 			
 			bool correct = TRUE;
 			int i;
 			
 			for (i=0; i<20; i++) {
				if(msg->key[i] != key_stored[(TOS_NODE_ID-2)/2][i]){//nodes 2,4,6,...->indexes 0,1,2,...
					correct = FALSE;
				}
			}
 			
			if (correct == TRUE){
				printf("Received a message with a valid key\n");
				printf("Key: %s\n", msg->key);
				
				address_coupled_device = call AMPacket.source( buf );//saving the address of the parent in the memory
				printf("Child's bracelet saves the folowing parent's address: %d\n", address_coupled_device);
				
				printf("Transmitting a response (Unicast)\n");
      			printfflush();
      			
      			paired = TRUE;
				respKey();	
			}else{
			printf("Received a message with a wrong key\n");
 			printf("MATCHED?: %s\n", formatBool(correct));
      		printfflush();
			}
		}
		
		if (TOS_NODE_ID %2 == 1 && paired == FALSE){//Parent receives something, phase 1
			key_msg_t* msg = (key_msg_t*)payload;
	
			if (msg->state == OK){
				printf("Received a message with an OK state\n");
				printf("State: %d\n", msg->state);
				printf("Pairing is fully complete\n");
      			
    			paired = TRUE;
    			
    			call TimerPairing.stop();
    			printf("Stopping pairing timer\n");
    			printfflush();
			}
			return buf;
		}
		
		if (TOS_NODE_ID % 2 == 1 && paired == TRUE && call AMPacket.source( buf ) == TOS_NODE_ID + 1){
		//Parent receives info, phase 2
 	 		
 			info_msg_t* msg = (info_msg_t*)payload;
 			
 			if (call TimerMissing.isRunning()){
 				call TimerMissing.stop();
 			}
 			 
			printf("Received a message from a child\n");
			
			printf("Was it broadcasted? %s\n",formatBool(call AMPacket.destination( buf ) == AM_BROADCAST_ADDR));
			
			printf("Payload\n");
			printf("X: %d\n", msg->X);
  			printf("Y: %d\n", msg->Y);
  			
  			switch (msg->status){
  			case STANDING:
  				printf("Status: STANDING\n");
      			printfflush();
  				break;
  		
  			case WALKING:
  				printf("Status: WALKING\n");
      			printfflush();
  				break;
  		
  			case RUNNING:
  				printf("Status: RUNNING\n");
      			printfflush();
  				break;
  				
  			case FALLING:
  				printf("Status: FALLING\n");
      			printfflush();
      			
      			fallAlarm(msg->X, msg->Y);
      			
  				break;
  			}
  			
      		X_last = msg->X;
      		Y_last = msg->Y;
      		
      		call TimerMissing.startPeriodic(60000);
      	}	
	return buf;
  }
}  


