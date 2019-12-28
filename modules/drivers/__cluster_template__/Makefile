
# Builds all drivers in this cluster

# Run the makefile (if there is one) in each individual driver directory

SUBDIRS = 1a 1ap 1b 1bp 2b 2bv1.2.32 

.PHONY: subdirs $(SUBDIRS)

subdirs: $(SUBDIRS)

$(SUBDIRS):
        $(MAKE) -C $@

foo: baz