#ifndef SENDACK_H
#define SENDACK_H

//payload of the msg
typedef nx_struct key_msg {
	nx_uint16_t state;
	nx_uint8_t key[20];
} key_msg_t;

typedef nx_struct info_msg {
	nx_uint16_t X;
	nx_uint16_t Y;
	nx_uint8_t status;
} info_msg_t;

//status
#define STANDING 10
#define WALKING 20
#define RUNNING 30
#define FALLING 40


#define OK 1
//#define KO 2 

enum{
AM_MY_MSG = 6,
};

#endif
