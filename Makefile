SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)
FFMPEG_LIBS=    libavformat                        \
                libavcodec                         \
                libswresample                      \
                libavutil                          \

CFLAGS += -Wall
LIBS = -lcurl -ljson-c -lao -lpthread -lcrypto
CFLAGS := $(shell pkg-config --cflags $(FFMPEG_LIBS)) $(CFLAGS)
LIBS := $(shell pkg-config --libs $(FFMPEG_LIBS)) $(LIBS)

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
