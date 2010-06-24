includes packet;
configuration TempSenseJ { }
implementation
{
	components Main, TempSenseJM, LedsC, HumidityC as Sensor, GenericComm as Comm, TimerC;

	Main.StdControl -> TempSenseJM;

	Main.StdControl -> TimerC;
  	TempSenseJM.Timer -> TimerC.Timer[unique("Timer")];

	TempSenseJM.Leds -> LedsC;

	TempSenseJM.SensorControl -> Sensor.SplitControl;
	TempSenseJM.Temp -> Sensor.Temperature;
	TempSenseJM.Humid -> Sensor.Humidity;

	TempSenseJM.CommControl -> Comm;
	TempSenseJM.DataMsg -> Comm.SendMsg[AM_XDMSG];
	// NEW!!!!!
	TempSenseJM.ForwardMsg -> Comm.ReceiveMsg[AM_XDMSG];


}
