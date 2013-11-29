SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)

LIBS = -lcurl -ljson-c -lao -lpthread -lcrypto -libavdevice -libavformat -libavfilter -libavcodec -libswresample -libswscale -libavutil
CFLAGS = -Wall

all: fmd

debug: CFLAGS += -g
debug: fmd

release: CFLAGS += -O2
release: fmd

fmd: ${OBJ}
	gcc ${CFLAGS} -o $@ $^ ${LIBS}

%.o: %.c
	gcc ${CFLAGS} -c $<

clean:
	-rm *.o
