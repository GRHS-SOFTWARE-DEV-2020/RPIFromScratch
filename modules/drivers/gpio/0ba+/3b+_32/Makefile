
# Makefile that has been generalized to use as an individual driver builder from a cluster's root
# Makefile will use the name of the assembly file within its directory to determine the output name

# Below settings should be checked between every individual driver's makefile

OUTPUT_PATH = ../../../../../build/hardware_drivers/arm_timer/
LINKER_SCRIPT_PATH = ../link.ld

TOOLCHAIN = arm-none-eabi

AS_FLAGS = --statistics
LD_FLAGS = -T $(LINKER_SCRIPT_PATH)
OBJCOPY_FLAGS = -O binary
OBJDUMP_FLAGS = -d

DRIVER_FAMILY = ARMTIMER
DRIVER_CLUSTER = BCM
DRIVER_VERSION = 0.0.1
DRIVER_TARGET = 3B+_32



# DO NOT CHANGE THESE OR IT BREAKS THE SCRIPT!

DRIVER = D_$(DRIVER_FAMILY)_$(DRIVER_CLUSTER)_$(DRIVER_VERSION)_$(DRIVER_TARGET)

SOURCE_FILE = $(DRIVER).s
OBJECT_FILE = $(DRIVER).o
LINK_FILE = $(DRIVER).elf
LIST_FILE = $(DRIVER).list
BUILD_FILE = $(OUTPUT_PATH)$(DRIVER).bin



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
