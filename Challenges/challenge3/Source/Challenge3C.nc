#include "printf.h"	
#include "Timer.h"

module Challenge3C {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
}

implementation {

  uint32_t quotient = 10816982;
  uint32_t remainder = 0;
  
  bool state0 = 0;//0 - off; 1 - on
  bool state1 = 0;
  bool state2 = 0;
  
  
  event void Boot.booted() {
  		
    call Timer0.startPeriodic(60000);//1min = 60 *10^3 ms	
  }
    
  event void Timer0.fired() {
  	if (quotient == 0){
  		//printf("Before: %d\n", call Timer0.isRunning());
  		call Timer0.stop();
  		//printf("DONE: %d\n", call Timer0.isRunning());
  		//printfflush();
  		return;
  	}
  		
  	remainder = quotient % 3;
  	quotient = quotient/3;
  	
  	switch (remainder){
  	case 0:
  		call Leds.led0Toggle();
  		//call Leds.get()
  		state0 = !state0;
  		break;
  		
  	case 1:
  		call Leds.led1Toggle();
  		state1 = !state1;
  		break;
  		
  	case 2:
  		call Leds.led2Toggle();
  		state2 = !state2;
  		break;
  	}
  	printf("%d%d%d\n", state0, state1, state2);//states of all LEDs together
  	printfflush();
  }
}

