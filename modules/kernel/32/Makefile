
# Makefile that has been generalized to use as an individual driver builder from a cluster's root
# Makefile will use the name of the assembly file within its directory to determine the output name

# Below settings should be checked between every individual driver's makefile

OUTPUT_PATH = ../../../build/kernel/
LINKER_SCRIPT_PATH = link.ld

TOOLCHAIN = arm-none-eabi

AS_FLAGS = --statistics
LD_FLAGS = -T $(LINKER_SCRIPT_PATH)
OBJCOPY_FLAGS = -O binary
OBJDUMP_FLAGS = -d

SOURCE = kernel32
TARGET = kernel

SOURCE_FILE = $(SOURCE).s
OBJECT_FILE = $(SOURCE).o
LINK_FILE = $(SOURCE).elf
LIST_FILE = $(SOURCE).list
BUILD_FILE = $(OUTPUT_PATH)$(TARGET).img



# Recipe for building this driver, do not touch! This should work across all platforms and just need the top section adjusted to function

ALL: BUILD_LIST

BUILD_LIST: $(LIST_FILE) $(BUILD_FILE)
	-rm -f $(LINK_FILE)

$(LIST_FILE): $(LINK_FILE)
	$(TOOLCHAIN)-objdump $(OBJDUMP_FLAGS) $(LINK_FILE) > $(LIST_FILE)
	-rm -f $(OBJECT_FILE)

$(BUILD_FILE): $(LINK_FILE)
	$(TOOLCHAIN)-objcopy $(OBJCOPY_FLAGS) $(LINK_FILE) $(BUILD_FILE)

$(LINK_FILE): $(OBJECT_FILE)
	$(TOOLCHAIN)-ld $(LD_FLAGS) -o $(LINK_FILE) $(OBJECT_FILE)

$(OBJECT_FILE): CLEAN
	$(TOOLCHAIN)-as $(AS_FLAGS) -o $(OBJECT_FILE) $(SOURCE_FILE)

CLEAN:
	-rm -f $(LIST_FILE)
