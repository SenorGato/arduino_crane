# Makefile for building Arduino sketches with Arduino 1.0.
#
# Makefile-arduino v0.8 by Bernard Pratz <guyzmo{at}hackable-devices.org>
# I release my changes under WTFPL2.0 licence, contact other authors for their favorite licences.
# Updates on : https://github.com/guyzmo/Arduino-Tools/blob/master/Makefile
#
# Makefile-arduino v0.7 by Akkana Peck <akkana@shallowsky.com>
# Adapted from a long-ago Arduino 0011 Makefile by mellis, eighthave, oli.keller
#
# This Makefile allows you to build sketches from the command line
# without the Arduino environment (or Java).
#
# Detailed instructions for using this Makefile:
#
#  1. Copy this file into the folder with your sketch.
#     There should be a file with the extension .pde (e.g. blink.pde).
#     cd into this directory. Be sure your directory has the same name
#     as the .pde file.
#
#  2. Modify the line containg "ARDUINO_DIR" to point to the directory that
#     contains the Arduino installation (for example, under Mac OS X, this
#     might be /Applications/arduino-1.0). If it's in your home directory,
#     you can include $(HOME) as part of the path.
#
#  3. Set MODEL to your Arduino model.
#     Tested so far on uno, atmega328, diecimila and mega.
#     but there are lots of other options:
#     Use the "make list" command to know all the available models
#
#  4. Run "make" to compile/verify your program.
#
#  5. Run "make upload" (and reset your Arduino if it requires it)
#     to download your program to the Arduino.
#
# Nota Bene:
# if reset does not work, add RESET_MODE='python' or RESET_MODE='perl' to your env
#  * Perl version needs libdevice-serialport-perl :
#  * Python version needs python-serial :
#
# If you want to support other hardwares, add them to the hardware directory and make
# so it contains at the root:
#  - boards.txt
#  - cores/
#  - bootloaders/
#  - variants/pins_arduino.h
# The only exception being for the ATTINY, which does not contain a variants directory
# To download the attiny boards support, have a look at http://code.google.com/p/arduino-tiny/

############################################################################
# Project's settings
############################################################################

VERSION = 0.1

# Standard Arduino libraries it will import, e.g. LiquidCrystal:
ARDLIBS = 

# User-specified (in ~/sketchbook/libraries/) libraries :
USERLIBS = 

# Libs in local directory for current project
# uncomment value if you have libs in directories inside current project's directory
LOCALLIBS = 

# Arduino model:
# You can set this to be a string, such as uno, atmega328...
# do 'make list' for a full list of supported models
MODEL ?= uno

# Here you can define 
DEFINES ?=

# 
TERM_SPEED ?= 115200

# in case you're using an external programmer, or you want to give more options, eg:
#	dragon_isp
#   avr_isp -e
#   wiring -e
PROGRAMMER ?=

############################################################################
# Platform's settings
############################################################################

# Determine operating system environment
ifneq "$(wildcard C:/Windows/)" ""
 UNAME=Windows
else
 UNAME=$(shell uname)
endif

# Name of the program and source .pde file:
TARGET = $(shell basename $(PWD))

# Where do you keep the official Arduino software package?
ARDUINO_DIR = /home/senoraraton/.arduino15/packages/arduino/hardware
HOME_LIB = $(HOME)/Documents/Arduino/libraries
BOARDS=$(wildcard $(ARDUINO_DIR)/hardware/*/boards.txt)
ATTINY_DIR=$(shell grep attiny /Applications/Arduino.app/Contents/Resources/Java/hardware/*/boards.txt | tail -1 | sed 's/boards\.txt.*//')

############################################################################
# Below here nothing should need to be changed. Cross your fingers!
############################################################################

# Where are tools like avr-gcc located on your system?
ifeq "$(UNAME)" "Darwin"
 AVR_TOOLS_PATH = $(ARDUINO_DIR)/hardware/tools/avr/1.8.6
else
 AVR_TOOLS_PATH = /usr/bin
endif

ifeq "$(UNAME)" "Windows"
 PORT ?= COM1 #XXX needs to be checked !
else
 ifeq "$(UNAME)" "Darwin"
  ifeq ($(MODEL),$(filter $(MODEL),uno leonardo))
   PORT ?= /dev/tty.usbmodem*
  else
   PORT ?= /dev/tty.usbserial*
  endif
 else
  ifeq "$(UNAME)" "Linux"
   ifeq ($(MODEL),$(filter $(MODEL),uno leonardo))
    PORT ?= /dev/ttyACM*
   else
    PORT ?= /dev/ttyUSB*
   endif
  endif
 endif
endif

# How to reset the device before downloading a new program.
# These don't always work; if the default one doesn't work,
# try uncommenting one of the others instead.
ifeq "$(RESET_MODE)" "python"
 RESET_DEVICE = python -c "import serial; s = serial.SERIAL('$(PORT)', 57600); s.setDTR(True); sleep(1); s.setDTR(False)"
else
 ifeq "$(RESET_MODE)" "perl"
  RESET_DEVICE = perl -MDevice::SerialPort -e 'Device::SerialPort->new("$(PORT)")->pulse_dtr_on(1000)'
 else
  ifeq "$(UNAME)" "Windows"
   RESET_DEVICE = echo "CAN'T RESET DEVICE ON WINDOWS !"
  else
   ifeq "$(UNAME)" "Linux"
    RESET_DEVICE = stty -F $(PORT) hupcl
   else
    # BSD uses small f
    RESET_DEVICE = stty -f $(PORT) hupcl
   endif
  endif
 endif
endif
# add 4 seconds of wait after reseting a leonardo device
ifeq "$(MODEL)" "leonardo"
 RESET_DEVICE="$(RESET_DEVICE);sleep 4"
endif

ifneq "$(shell which miniterm.py)" "miniterm.py not found"
 TERM=$(shell which miniterm.py) $(TERM_SPEED) $(PORT)
else
 ifneq $(shell which screen), "screen not found"
  TERM=$(shell which screen) $(TERM_SPEED) $(PORT)
 else
  $(warning screen or miniterm not found. Cannot run terminal)
  TERM=
 endif
endif

#
# Set up values according to what the IDE uses:
#
VARIANT ?= $(shell grep "^$(MODEL)\." $(BOARDS) | grep build.variant | sed 's/.*=//')
VARIANT_DIR = $(shell grep '^$(MODEL)' $(BOARDS) | grep variant | sed 's/\(.*\)boards.txt:.*/\1/')
UPLOAD_RATE ?= $(shell grep "^$(MODEL)\." $(BOARDS) | grep upload.speed | sed 's/.*=//')
MCU = $(shell grep "^$(MODEL)\." $(BOARDS) | grep build.mcu | sed 's/.*=//')
F_CPU = $(shell grep "^$(MODEL)\." $(BOARDS) | grep build.f_cpu | sed 's/.*=//')

# man avrdude says to use arduino, but the IDE mostly uses stk500.
# One rumor says that the difference is that arduino does an auto-reset, stk500 doesn't.
# Might want to grep for upload.protocol as with previous 3 values.
ifneq ($(findstring tiny,$(MODEL)),)
AVRDUDE_PROGRAMMER =  $(shell grep "^$(MODEL)\." $(BOARDS) | grep upload.using | sed 's/.*=\(.*\):.*/\1/')
 ARDUINO_CORE=$(ATTINY_DIR)/cores/tiny
 ARDUINO_VARIANT=$(ATTINY_DIR)/cores/tiny
 ARDUINO_PROG_HEADER=WProgram.h
 SRC=$(ARDUINO_CORE)/pins_arduino.c
 ifeq ($(UPLOAD_RATE),)
   UPLOAD_RATE=9600
 endif
else
 ifeq ("$(PROGRAMMER)", "")
  AVRDUDE_PROGRAMMER = $(shell grep "^$(MODEL)\." $(BOARDS) | grep upload.using | sed 's/.*=//')
 else
  AVRDUDE_PROGRAMMER = $(PROGRAMMER)
 endif
 ARDUINO_CORE=$(ARDUINO_DIR)/hardware/arduino/cores/arduino
 ARDUINO_PROG_HEADER=Arduino.h
 SRC=

 # This has only been tested on standard variants. I'm guessing
 # at what mega and micro might need; other possibilities are
 # leonardo and "eightanaloginputs".
 ifeq "$(MODEL)" "mega"
  ARDUINO_VARIANT=$(ARDUINO_DIR)/hardware/arduino/variants/mega
 else
  ifeq "$(MODEL)" "micro"
   ARDUINO_VARIANT=$(ARDUINO_DIR)/hardware/arduino/variants/micro
  else
   ifeq "$(MODEL)" "leonardo"
    ARDUINO_VARIANT=$(ARDUINO_DIR)/hardware/arduino/variants/leonardo
   else
    ARDUINO_VARIANT=$(VARIANT_DIR)/variants/$(VARIANT)
   endif
  endif
 endif
endif

CWDBASE = $(shell basename $(PWD))
TARFILE = $(TARGET)-$(VERSION).tar.gz

# $(ARDUINO_DIR)/hardware/arduino/variants/standard/pins_arduino.c
SRC += \
    $(ARDUINO_CORE)/wiring.c \
    $(ARDUINO_CORE)/wiring_analog.c $(ARDUINO_CORE)/wiring_digital.c \
    $(ARDUINO_CORE)/wiring_pulse.c \
    $(ARDUINO_CORE)/wiring_shift.c $(ARDUINO_CORE)/WInterrupts.c \
    $(foreach l,$(ARDLIBS),$(wildcard $(ARDUINO_DIR)/libraries/$l/*.c)) \
    $(foreach l,$(USERLIBS),$(wildcard $(HOME_LIB)/$l/*.c)) \
    $(foreach l,$(LOCALLIBS),$(wildcard $l/*.c))

CXXSRC = $(ARDUINO_CORE)/HardwareSerial.cpp $(ARDUINO_CORE)/WMath.cpp \
    $(ARDUINO_CORE)/WString.cpp $(ARDUINO_CORE)/Print.cpp \
	$(ARDUINO_CORE)/USBCore.cpp $(ARDUINO_CORE)/HID.cpp $(ARDUINO_CORE)/CDC.cpp \
    $(foreach l,$(ARDLIBS),$(wildcard $(ARDUINO_DIR)/libraries/$l/*.cpp)) \
    $(foreach l,$(USERLIBS),$(wildcard $(HOME_LIB)/$l/*.cpp)) \
    $(foreach l,$(LOCALLIBS),$(wildcard $l/*.cpp))

FORMAT = ihex

# Name of this Makefile (used for "make depend").
MAKEFILE = Makefile

# Debugging format.
# Native formats for AVR-GCC's -g are stabs [default], or dwarf-2.
# AVR (extended) COFF requires stabs, plus an avr-objcopy run.
DEBUG = stabs

OPT = s

# Place -D or -U options here
ifeq "$(MODEL)" "leonardo"
 CDEFS = -DF_CPU=$(F_CPU) -DUSB_VID=0x2341 -DUSB_PID=0x0036
else
 CDEFS = -DF_CPU=$(F_CPU)
endif

PPDEFINES = $(foreach DEFINE,$(DEFINES),-D$(DEFINE))

# Include directories
CINCS = -I$(ARDUINO_CORE) -I$(ARDUINO_VARIANT) \
		$(patsubst %,-I$(ARDUINO_DIR)/libraries/%,$(ARDLIBS)) \
		$(patsubst %,-I$(HOME_LIB)/%,$(USERLIBS)) \
		$(patsubst %,-I%/,$(LOCALLIBS))

# Compiler flag to set the C Standard level.
# c89   - "ANSI" C
# gnu89 - c89 plus GCC extensions
# c99   - ISO C99 standard (not yet fully implemented)
# gnu99 - c99 plus GCC extensions
CSTANDARD = -std=gnu99
CXXSTANDARD = -std=gnu++11
CDEBUG = -g$(DEBUG)
CWARN = -Wall -Wstrict-prototypes
CTUNING = -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
#CEXTRA = -Wa,-adhlns=$(<:.c=.lst)

# Extra flags to match what the Arduino 1.0 IDE is doing:
# Something about the -ffunction-sections -fdata-sections reduces
# final text size by roughly half!
CEXTRA= -g -Os -Wall -fno-exceptions -ffunction-sections -fdata-sections -DARDUINO=100

CFLAGS = $(CDEBUG) $(PPDEFINES) $(CDEFS) $(CINCS) -O$(OPT) $(CWARN) $(CSTANDARD) $(CEXTRA)
CXXFLAGS = $(CDEFS) $(PPDEFINES) $(CINCS) -O$(OPT) $(CXXSTANDARD) $(CEXTRA)
#ASFLAGS = -Wa,-adhlns=$(<:.S=.lst),-gstabs 
LDFLAGS = -Os -Wl,--gc-sections -mmcu=$(MCU) -lm

# Programming support using avrdude. Settings and variables.
AVRDUDE_WRITE_FLASH = -U flash:w:applet/$(TARGET).hex
ifeq "$(UNAME)" "Darwin"
AVRDUDE_CONF = -V -F -C $(ARDUINO_DIR)/hardware/tools/avr/etc/avrdude.conf
else
AVRDUDE_CONF = -V -F -C /etc/avrdude.conf
endif
AVRDUDE_FLAGS = $(AVRDUDE_CONF) \
    -p $(MCU) -P $(PORT) -c $(AVRDUDE_PROGRAMMER) \
    -b $(UPLOAD_RATE)

# Program settings
CC = $(AVR_TOOLS_PATH)/avr-gcc
CXX = $(AVR_TOOLS_PATH)/avr-g++
OBJCOPY = $(AVR_TOOLS_PATH)/avr-objcopy
OBJDUMP = $(AVR_TOOLS_PATH)/avr-objdump
AR  = $(AVR_TOOLS_PATH)/avr-ar
SIZE = $(AVR_TOOLS_PATH)/avr-size
NM = $(AVR_TOOLS_PATH)/avr-nm
AVRDUDE = $(AVR_TOOLS_PATH)/avrdude
REMOVE = rm -f
MV = mv -f

# Define all object files.
OBJ = $(SRC:.c=.o) $(CXXSRC:.cpp=.o) $(ASRC:.S=.o)

# Define all listing files.
LST = $(ASRC:.S=.lst) $(CXXSRC:.cpp=.lst) $(SRC:.c=.lst)

# Combine all necessary flags and optional flags.
# Add target processor to flags.
ALL_CFLAGS = -mmcu=$(MCU) -I. $(CFLAGS)
ALL_CXXFLAGS = -mmcu=$(MCU) -I. $(CXXFLAGS)
ALL_ASFLAGS = -mmcu=$(MCU) -I. -x assembler-with-cpp $(ASFLAGS)

# Default target.
all: applet_files build sizeafter

test:
	@echo CXXSRC = $(CXXSRC)

build: elf hex 

ifneq "$(wildcard $(TARGET).pde)" ""
applet/$(TARGET).cpp: $(TARGET).pde
	# Here is the "preprocessing".
	# It creates a .cpp file based with the same name as the .pde file.
	# On top of the new .cpp file comes the WProgram.h header.
	# At the end there is a generic main() function attached,
	# plus special magic to get around the pure virtual error
	# undefined reference to `__cxa_pure_virtual' from Print.o.
	# Then the .cpp file will be compiled. Errors during compile will
	# refer to this new, automatically generated, file. 
	# Not the original .pde file you actually edit...
	test -d applet || mkdir applet
	echo '#include "$(ARDUINO_PROG_HEADER)"' > applet/$(TARGET).cpp
	cat $(TARGET).pde >> applet/$(TARGET).cpp
	echo 'extern "C" void __cxa_pure_virtual() { while (1) ; }' >> applet/$(TARGET).cpp
	cat $(ARDUINO_CORE)/main.cpp >> applet/$(TARGET).cpp
else
 ifneq "$(wildcard $(TARGET).ino)" ""
applet/$(TARGET).cpp: $(TARGET).ino
	# Here is the "preprocessing".
	# It creates a .cpp file based with the same name as the .ino file.
	# On top of the new .cpp file comes the WProgram.h header.
	# At the end there is a generic main() function attached,
	# plus special magic to get around the pure virtual error
	# undefined reference to `__cxa_pure_virtual' from Print.o.
	# Then the .cpp file will be compiled. Errors during compile will
	# refer to this new, automatically generated, file. 
	# Not the original .ino file you actually edit...
	test -d applet || mkdir applet
	echo '#include "$(ARDUINO_PROG_HEADER)"' > applet/$(TARGET).cpp
	cat $(TARGET).ino >> applet/$(TARGET).cpp
	echo 'extern "C" void __cxa_pure_virtual() { while (1) ; }' >> applet/$(TARGET).cpp
	cat $(ARDUINO_CORE)/main.cpp >> applet/$(TARGET).cpp
else
applet/$(TARGET).cpp:
	@echo "FAILURE: Missing .pde or .ino file in current directory !"
	@exit 2
endif
endif

elf: applet/$(TARGET).elf
hex: applet/$(TARGET).hex
eep: applet/$(TARGET).eep
lss: applet/$(TARGET).lss 
sym: applet/$(TARGET).sym

reset:
	$(RESET_DEVICE)

# Program the device.  
upload: applet/$(TARGET).hex
	$(AVRDUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_WRITE_FLASH)

	# Display size of file.
HEXSIZE = $(SIZE) --target=$(FORMAT) applet/$(TARGET).hex
ELFSIZE = $(SIZE)  applet/$(TARGET).elf
sizebefore:
	@if [ -f applet/$(TARGET).elf ]; then echo; echo $(MSG_SIZE_BEFORE); $(HEXSIZE); echo; fi

sizeafter:
	@if [ -f applet/$(TARGET).elf ]; then echo; echo $(MSG_SIZE_AFTER); $(HEXSIZE); echo; fi

# Convert ELF to COFF for use in debugging / simulating in AVR Studio or VMLAB.
COFFCONVERT=$(OBJCOPY) --debugging \
    --change-section-address .data-0x800000 \
    --change-section-address .bss-0x800000 \
    --change-section-address .noinit-0x800000 \
    --change-section-address .eeprom-0x810000 

coff: applet/$(TARGET).elf
	$(COFFCONVERT) -O coff-avr applet/$(TARGET).elf $(TARGET).cof


extcoff: $(TARGET).elf
	$(COFFCONVERT) -O coff-ext-avr applet/$(TARGET).elf $(TARGET).cof

.SUFFIXES: .elf .hex .eep .lss .sym

.elf.hex:
	$(OBJCOPY) -O $(FORMAT) -R .eeprom $< $@

.elf.eep:
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
	--change-section-lma .eeprom=0 -O $(FORMAT) $< $@

# Create extended listing file from ELF output file.
.elf.lss:
	$(OBJDUMP) -h -S $< > $@

# Create a symbol table from ELF output file.
.elf.sym:
	$(NM) -n $< > $@

	# Link: create ELF output file from library.
applet/$(TARGET).elf: applet/$(TARGET).o applet/core.a 
	$(CC) -o $@ applet/$(TARGET).o -L. applet/core.a $(LDFLAGS)

#applet/$(TARGET).elf: applet/$(TARGET).o applet/core.a 
#	$(CC) $(ALL_CFLAGS) -o $@ applet/$(TARGET).cpp -L. applet/core.a $(LDFLAGS)

applet/core.a: $(OBJ)
	@for i in $(OBJ); do echo $(AR) rcs applet/core.a $$i; $(AR) rcs applet/core.a $$i; done

# Compile: create object files from C++ source files.
.cpp.o:
	$(CXX) -c $(ALL_CXXFLAGS) $< -o $@ 

# Compile: create object files from C source files.
.c.o:
	$(CC) -c $(ALL_CFLAGS) $< -o $@ 


# Compile: create assembler files from C source files.
.c.s:
	$(CC) -S $(ALL_CFLAGS) $< -o $@


# Assemble: create object files from assembler source files.
.S.o:
	$(CC) -c $(ALL_ASFLAGS) $< -o $@

# Target: clean project.
clean:
	$(REMOVE) applet/$(TARGET).eep applet/$(TARGET).cof applet/$(TARGET).elf \
	applet/$(TARGET).map applet/$(TARGET).sym applet/$(TARGET).lss applet/core.a \
	$(OBJ) $(LST) $(SRC:.c=.s) $(SRC:.c=.d) $(CXXSRC:.cpp=.s) $(CXXSRC:.cpp=.d)

flush:
	$(REMOVE) -rf applet/ \
	$(REMOVE) $(OBJ) $(LST) $(SRC:.c=.s) $(SRC:.c=.d) $(CXXSRC:.cpp=.s) $(CXXSRC:.cpp=.d)

list:
	# LIST OF ALL THE BOARDS AVAILABLE AS TARGETS FOR $$MODEL ENV VARIABLE
	@cat $(BOARDS)  | grep '.name' \
					| sed 's/\(.*\)\.name=\(.*\)/MODEL=\1;\2/' \
					| column -t -s';'

term:
	$(TERM)

tar: $(TARFILE)

$(TARFILE): 
	( cd .. && \
	  tar czvf $(TARFILE) --exclude=applet --owner=root $(CWDBASE) && \
	  mv $(TARFILE) $(CWD) && \
	  echo Created $(TARFILE) \
	)

depend:
	if grep '^# DO NOT DELETE' $(MAKEFILE) >/dev/null; \
	then \
		sed -e '/^# DO NOT DELETE/,$$d' $(MAKEFILE) > \
			$(MAKEFILE).$$$$ && \
		$(MV) $(MAKEFILE).$$$$ $(MAKEFILE); \
	fi
	echo '# DO NOT DELETE THIS LINE -- make depend depends on it.' \
		>> $(MAKEFILE); \
	$(CC) -M -mmcu=$(MCU) $(CDEFS) $(CINCS) $(SRC) $(ASRC) >> $(MAKEFILE)

.PHONY:	all build elf hex eep lss sym program coff extcoff clean depend applet_files sizebefore sizeafter


