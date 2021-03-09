
/************************************************************
* This script is based on the ShieldEkgEmgDemo by Olimex
* It is a simpler version of the Olimex-Script to collect ecg data from 
* the Olimex Shield and an Arduino
* Copyright (c) 2002-2003, Joerg Hansmann, Jim Peters, Andreas Robinson
* License: GNU General Public License (GPL) v2
***********************************************************/


/************************************************************
Package structure (6Byte package)
uint8_t	sync0;		  // = 0xa5
uint8_t	sync1;		  // = 0x5a
uint8_t	count;		  // packet counter. Increases by 1 each packet.
uint16_t	data[2];	// 10-bit sample (= 0 - 1023) in big endian (Motorola) format.
uint8_t	switches;	  // State of PD5 to PD2, in bits 3 to 0.
***********************************************************/

#include <compat/deprecated.h>
#include <FlexiTimer2.h>                  //http://www.arduino.cc/playground/Main/FlexiTimer2

// All definitions
#define NUMCHANNELS 1                     // 6 Channels are possible, only one is used
#define HEADERLEN 3
#define PACKETLEN (NUMCHANNELS * 2 + HEADERLEN + 1)
#define SAMPFREQ 256                      // ADC sampling rate 256
#define TIMER2VAL (1024/(SAMPFREQ))       // Set 256Hz sampling frequency                    
#define LED1  13

// Global constants and variables
volatile unsigned char TXBuf[PACKETLEN];  //The transmission packet
volatile unsigned char TXIndex;           //Next byte to write in the transmission packet.
volatile unsigned char counter = 0;	      //Additional divider used to generate CAL_SIG
volatile unsigned int ADC_Value = 0;	    //ADC current value

//~~~~~~~~~~
// Functions
//~~~~~~~~~~

/****************************************************/
/*  Function name: Toggle_LED1                      */
/*  Parameters                                      */
/*    Input   :  No	                            */
/*    Output  :  No                                 */
/*    Action: Switches-over LED1.                   */
/****************************************************/
void Toggle_LED1(void){

 if((digitalRead(LED1))==HIGH){ digitalWrite(LED1,LOW); }
 else{ digitalWrite(LED1,HIGH); }
 
}


/****************************************************/
/*  Function name: setup Buffer & FlexiTimer2       */
/*  Parameters                                      */
/*    Input   :  No	                                */
/*    Output  :  No                                 */
/*    Action: Initializes all peripherals           */
/****************************************************/
void setup() {

 noInterrupts();  // Disable all interrupts before initialization
 
 // LED1
 pinMode(LED1, OUTPUT);  //Setup LED1 direction
 digitalWrite(LED1,LOW); //Setup LED1 state
 
 //Write packet header and footer
 TXBuf[0] = 0xa5;    //Sync 0
 TXBuf[1] = 0x5a;    //Sync 1
 TXBuf[2] = 0;       //Packet counter
 TXBuf[3] = 0x02;    //CH1 High Byte
 TXBuf[4] = 0x00;    //CH1 Low Byte
 TXBuf[5] =  0x01;	// Switches state

 // Timer2
 // Timer2 is used to setup the analag channels sampling frequency and packet update.
 // Whenever interrupt occures, the current read packet is sent to the PC
 FlexiTimer2::set(TIMER2VAL, Timer2_Overflow_ISR);
 FlexiTimer2::start();
 
 // Serial Port
 //Set baudrate to 57600 bps
 Serial.begin(57600);
 
 interrupts();  // Enable all interrupts after initialization has been completed
}

/****************************************************/
/*  Function name: Timer2_Overflow_ISR              */
/*  Parameters                                      */
/*    Input   :  No	                            */
/*    Output  :  No                                 */
/*    Action: Determines ADC sampling frequency.    */
/****************************************************/
void Timer2_Overflow_ISR()
{
  // Toggle LED1 with ADC sampling frequency /2
  Toggle_LED1();
  
  //Read the Channel 1 ADC inputs and store values in packet (Analog Pin: A0)
  ADC_Value = analogRead(0);
  TXBuf[3] = ((unsigned char)((ADC_Value & 0xFF00) >> 8));	// Write High Byte
  TXBuf[4] = ((unsigned char)(ADC_Value & 0x00FF));	// Write Low Byte
	 
  // Send Packet
  for(TXIndex=0;TXIndex<6;TXIndex++){
    Serial.write(TXBuf[TXIndex]);
  }
  
  // Increment the packet counter
  TXBuf[3]++;			
}


/****************************************************/
/*  Function name: loop                             */
/*  Parameters                                      */
/*    Input   :  No	                            */
/*    Output  :  No                                 */
/*    Action: Puts MCU into sleep mode.             */
/****************************************************/
void loop() {
  
 __asm__ __volatile__ ("sleep");
 
}
