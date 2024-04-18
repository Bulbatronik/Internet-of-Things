#include "bracelets.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration braceletsAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, braceletsC as App;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components new TimerMilliC() as TimerPairing;
  components new TimerMilliC() as TimerOperation;
  components new TimerMilliC() as TimerMissing;
  components ActiveMessageC;
  components SerialPrintfC;// to avoid the unreadable characters
  components SerialStartC;
  components RandomC;
  
  //components Random;
  //add the other components here

/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  
  //Radio Control
  App.SplitControl -> ActiveMessageC;
  
  //Interfaces to access package fields
  App.Packet -> AMSenderC;
  App.PacketAcknowledgements->ActiveMessageC;
  App.AMPacket->AMSenderC;
  
  //Timer interface
  App.TimerPairing -> TimerPairing;
  App.TimerOperation -> TimerOperation;
  App.TimerMissing -> TimerMissing;
  
  //Random interface
	App.Random -> RandomC;
	RandomC <- MainC.SoftwareInit;
}

