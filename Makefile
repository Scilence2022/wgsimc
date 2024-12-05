CC = gcc
CFLAGS = -g -O2 -Wall
LDFLAGS = -lz -lm
TARGET = wgsimc
SRC = wgsimc.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)

clean:
	rm -f $(TARGET) 