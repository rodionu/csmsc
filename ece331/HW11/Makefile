TARGET=rtcl
OBJS=rtc.o reader.o
CFLAGS=-g -Wall
LIBS=
.PHONY:all clean
all:$(TARGET)
$(TARGET):$(OBJS)
	$(CC) $(LIBS) -o $(TARGET) $(OBJS)
clean:
	rm -f *.o core* $(TARGET)
