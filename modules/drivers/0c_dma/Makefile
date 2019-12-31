
GNU_TOOL = arm-none-eabi

NAME = D_DMA

MCPU = cortex-a53
MARCH = armv8-a
AS_FLAGS = -mcpu=$(MCPU) -march=$(MARCH)

OBJECT_FILE = $(NAME).out



LINKER_SCRIPT = $(NAME).ld
MAP_FILE = $(NAME).map
LD_FLAGS = -Map=$(MAP_FILE) -T $(LINKER_SCRIPT) 

LINKED_FILE = $(NAME).elf



OCPY_OUT_FORMAT = binary
OCPY_FLAGS = -O $(OCPY_OUT_FORMAT)

IMAGE_FILE = $(NAME).bin



ODMP_FLAGS = -d

LIST_FILE = $(NAME).list

ASM_SOURCES := $(wildcard *.s)



# just about done for now.
all: $(IMAGE_FILE) $(LIST_FILE)


# put together the list file for debugging purposes and to check output
$(LIST_FILE) : $(LINKED_FILE)
	$(GNU_TOOL)-objdump $(ODMP_FLAGS) $(LINKED_FILE) > $(LIST_FILE)
	-rm -f $(OBJECT_FILE)
	-rm -f $(LINKED_FILE)
	-rm -f $(MAP_FILE)


# run the objcopy to move the output file into a .img from the .elf format
$(IMAGE_FILE) : $(LINKED_FILE)
	$(GNU_TOOL)-objcopy $(OCPY_FLAGS) $(LINKED_FILE) $(IMAGE_FILE)


# run the linker to make our .elf file
$(LINKED_FILE) : $(OBJECT_FILE)
	$(GNU_TOOL)-ld $(LD_FLAGS) -o $(LINKED_FILE) $(OBJECT_FILE)


# smash the assembly files into a single object file, very simple for now
$(OBJECT_FILE) : CLEAN
	$(GNU_TOOL)-as $(AS_FLAGS) -o $(OBJECT_FILE) $(ASM_SOURCES)


CLEAN:
	-rm -f $(OBJECT_FILE)
	-rm -f $(LINKED_FILE)
	-rm -f $(MAP_FILE)
	-rm -f $(IMAGE_FILE)
	-rm -f $(LIST_FILE)
