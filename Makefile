SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)
ALL_LIBS=    libavformat                        \
             libavcodec                         \
             libswresample                      \
             libavutil                          \
             libcurl                            \
             json-c                             \
             ao                                 \
             libcrypto                          \

CFLAGS += -Wall
LIBS = -lpthread
CFLAGS := $(shell pkg-config --cflags $(ALL_LIBS)) $(CFLAGS)
LIBS := $(shell pkg-config --libs $(ALL_LIBS)) $(LIBS)

all: rpd

debug: CFLAGS += -g
debug: rpd

release: CFLAGS += -O2
release: rpd

rpd: ${OBJ}
	gcc ${CFLAGS} -o $@ $^ ${LIBS}

%.o: %.c
	gcc ${CFLAGS} -c $<

clean:
	-rm *.o
