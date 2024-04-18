#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration Challenge3AppC{
}
implementation {
  components MainC, LedsC, Challenge3C;
  components new TimerMilliC() as Timer0;
  components SerialPrintfC;
  components SerialStartC;


  Challenge3C.Boot -> MainC;
  Challenge3C.Timer0 -> Timer0;
  Challenge3C.Leds -> LedsC;
}

