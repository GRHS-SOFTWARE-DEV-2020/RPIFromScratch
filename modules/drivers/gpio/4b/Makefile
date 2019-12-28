
# Builds all drivers in this cluster

# Run the makefile (if there is one) in each individual driver directory

DRIVERS = 1a 1a+ 1b 1b+ 2b 2bv1.2.32 2bv1.2_32 2bv1.2_64 3a+_32 3a+_64 3b_32 3b_64 3b+_32 3b+_64 4b_32 4b_64

all: subdirs

subdirs:
        for dir in $(DRIVERS); do \
          $(MAKE) -C $$dir; \
        done
        