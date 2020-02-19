
# Makefile that has been generalized to use as an individual driver builder from a cluster's root
# Makefile will use the name of the assembly file within its directory to determine the output name

# Below settings should be checked between every individual driver's makefile

OUTPUT_PATH = ../../../../build/drivers/0p_irq/
LINKER_SCRIPT_PATH = link.ld

TOOLCHAIN = arm-none-eabi

AS_FLAGS = --statistics
LD_FLAGS = -T $(LINKER_SCRIPT_PATH)
OBJCOPY_FLAGS = -O binary
OBJDUMP_FLAGS = -d

DRIVER_FAMILY = irq
DRIVER_NAME = 0p1000
DRIVER_WIDTH = 32



# DO NOT CHANGE THESE OR IT BREAKS THE SCRIPT!

DRIVER = $(DRIVER_NAME)-$(DRIVER_WIDTH)-$(DRIVER_FAMILY)

SOURCE_FILE = irq_0p1000.s
OBJECT_FILE = $(DRIVER).o
LINK_FILE = $(DRIVER).elf
LIST_FILE = $(DRIVER).list
BUILD_FILE = $(OUTPUT_PATH)$(DRIVER).bin



# Recipe for building this driver, do not touch! This should work across all platforms and just need the top section adjusted to function

ALL: $(LIST_FILE) $(BUILD_FILE)

$(LIST_FILE): $(LINK_FILE)
	$(TOOLCHAIN)-objdump $(OBJDUMP_FLAGS) $(LINK_FILE) > $(LIST_FILE)
	-rm -f $(OBJECT_FILE)

$(BUILD_FILE): $(LINK_FILE)
	$(TOOLCHAIN)-objcopy $(OBJCOPY_FLAGS) $(LINK_FILE) $(BUILD_FILE)

$(LINK_FILE): $(OBJECT_FILE)
	$(TOOLCHAIN)-ld $(LD_FLAGS) -o $(LINK_FILE) $(OBJECT_FILE)

$(OBJECT_FILE):
	$(TOOLCHAIN)-as $(AS_FLAGS) -o $(OBJECT_FILE) $(SOURCE_FILE)

