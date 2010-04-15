CC=avr-gcc
CFLAGS=-g -Os -Wall -mcall-prologues -mmcu=atmega88p
OBJ2HEX=avr-objcopy
VPATH=src
TARGET=AVRlab
OBJS=lab7a.o atod.o
#OBJS=lab06B.o serialutil.o
ADFLAGS=-i 1 -F -p m88p -c Bruce -P /dev/ttyUSB1
ADFLAG_PAR=-p m88p -F -v -c dapa -P /dev/parport0

.PHONY: fuses prog prog_par erase help

prog:$(TARGET).hex $(TARGET).eeprom
	avrdude $(ADFLAGS) -V -U flash:w:$(TARGET).hex:i
#	avrdude $(ADFLAGS) -U eeprom:w:$(TARGET).eeprom:i

prog_par:$(TARGET).hex $(TARGET).eeprom
	avrdude $(ADFLAG_PAR) -V -U flash:w:$(TARGET).hex:i
	echo "File complete!"
#This command still needs FIXING~!

%.obj:$(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@

#%.obj:%.o
#	$(CC) $(CFLAGS) $< -o $@

%.hex:%.obj
	$(OBJ2HEX) -R .eeprom -O ihex $< $@

%.eeprom:%.obj
	$(OBJ2HEX) -j .eeprop -O ihex $< $@

erase:
	avrdude $(ADFLAGS) -E noreset -e
clean:
	rm -f *.hex *.obj *.o *.eeprom

#fuses:
#	avrdude $(ADFLAGS) -F -U lfuse:w:lfuses.txt:s
#	avrdude $(ADFLAGS) -F -U hfuse:w:hfuse.txt:s
#	avrdude $(ADFLAGS) -F -U efuse:w:efuse.txt:s
#	avrdude $(ADFLAGS) -F -U lock:w:lock.txt:s

#check-fuses:
#	avrdude $(ADFLAGS)  -U lfuse:r:lfuses.txt:s
#	avrdude $(ADFLAGS)  -U hfuse:r:hfuse.txt:s
#	avrdude $(ADFLAGS)  -U efuse:r:efuse.txt:s
#	avrdude $(ADFLAGS)  -U lock:r:lock.txt:s
var:
	avrdude $(ADFLAG_PAR) -V -U flash:v:$(TARGET).hex:i
help:
	@echo 
	@echo This is the help section
	@echo prog_par = Program in parallel
	@echo prog = Program with FT232
	@echo erase = Erase the chip with FT232
	@echo erase_par = Not Implimented
	@echo clean = Clean up the directory
	@echo 
