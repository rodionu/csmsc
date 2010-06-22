
includes packet;
#define NUMSAMP 10

module TempSenseJM {
	provides interface StdControl;
	uses {
		interface Leds;
		interface Timer;
		interface ReceiveMsg;

		interface SplitControl as SensorControl;
		interface ADC as Temp;
		interface ADC as Humid;

		interface StdControl as CommControl;
		interface SendMsg as DataMsg;
		interface ReceiveMsg as RecMsg;
		
	}
}
implementation {
	norace uint32_t avhumid,avtemp;
	norace uint16_t packetnum=0;	//keeps track of packet number
	norace uint8_t count;		//number of samples to average
	norace TOS_Msg msg;
	//norace TOS_MsgPtr saved;
	norace XDataMsg* data;
	norace XDataMsg tempData;
	
	//////////////////////////////////////////////////////////
	// TASKS TO INITIALIZE CONVERSION AND MESSAGE SEND
	//////////////////////////////////////////////////////////
	task void initialize() {
		atomic data = (XDataMsg*)&msg.data;
		atomic data->node_id = TOS_LOCAL_ADDRESS;
	}	
	task void get_temp() {
		call Temp.getData();
	}
	task void get_humid() {
		call Humid.getData();
	}
	task void send_msg() {
		data->packet_id=packetnum;
		packetnum++;	
		if (call DataMsg.send(TOS_BCAST_ADDR,sizeof(XDataMsg),&msg)!=SUCCESS)
//			call Leds.greenToggle();
//		else
			call Leds.redToggle();
	}
	task void forward_msg() {
		if (call DataMsg.send(TOS_BCAST_ADDR,sizeof(XDataMsg),&msg)!=SUCCESS)
//			call Leds.yellowToggle();
//		else
			call Leds.redToggle();
	}
	
	//////////////////////////////////////////////////////////
	// DEFAULT START/INIT/STOP FUNCTIONS
	//////////////////////////////////////////////////////////
	command result_t StdControl.init() {
		call Leds.init();
		call SensorControl.init();
		call CommControl.init();
		return SUCCESS;
	}
	command result_t StdControl.start() {
		call CommControl.start();
		post initialize();
		return SUCCESS;
	}
	command result_t StdControl.stop() {
		call Timer.stop();
		call SensorControl.stop();
		call CommControl.stop();
		return SUCCESS;
	}
	event result_t SensorControl.initDone() {
		call Leds.greenOn();
		call SensorControl.start();
		return SUCCESS;
	}
	event result_t SensorControl.startDone() {
		call Leds.redOn();
		call Timer.start(TIMER_REPEAT,10000);
		return SUCCESS;
	}
	event result_t SensorControl.stopDone() {
		return SUCCESS;
	}

	////////////////////////////////////////////////////////////
	// EVENTS CREATED BY ADC FINISHING CONVERSION
	////////////////////////////////////////////////////////////
	event result_t Timer.fired() {
		call Leds.yellowToggle();
		call Leds.redOff();
		atomic count=0;
		atomic avtemp=0;
		atomic avhumid=0;
		post get_temp();
		return SUCCESS;
	}
	async event result_t Temp.dataReady(uint16_t t) {
		atomic avtemp = avtemp+t;
		post get_humid();
		return SUCCESS;
	}
	async event result_t Humid.dataReady(uint16_t t) {
		atomic avhumid = avhumid+t;
		count++;
		if (count<NUMSAMP)
			post get_temp();
		else {
			atomic data->temp = avtemp/NUMSAMP;
			atomic data->humid = avhumid/NUMSAMP;
			post send_msg();
		}
		return SUCCESS;
	}

	/////////////////////////////////////////////////////////////
	// EVENT CREATED BY FINISHING RADIO SEND
	/////////////////////////////////////////////////////////////
	event result_t DataMsg.sendDone(TOS_MsgPtr sent, result_t success) {
		if (success==SUCCESS)
			call Leds.greenToggle();
		return SUCCESS;
	}

	/////////////////////////////////////////////////////////////
	// EVENT CREATED BY RECEIVING MESSAGE ??????????????????????
	/////////////////////////////////////////////////////////////
	event result_t RecMsg.receive(TOS_MsgPtr received, result_t success) {
		msg = *received;
		post forward_msg();
	}
}
