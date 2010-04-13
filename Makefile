PYTHON ?= python
SWIG ?= swig
BUILD ?= build

DATABASE_TYPES = adb bdb fdb hdb tdb
IFACE ?= interface
SRC ?= src
SOURCES = $(DATABASE_TYPES:%=$(IFACE)/%.i) $(IFACE)/tcmaps.i $(IFACE)/ecode.i
C_SOURCES := $(DATABASE_TYPES:%=$(SRC)/cabinet/%.c) 
TCUCODEC ?= tcucodec
SWIG_OPTIONS += -modern
SWIG_OPTIONS += $(SHELL $(TCUCODEC) -i)

all: $(C_SOURCES) 

$(PKG)/stamp: $(C_SOURCES) $(PKG)/cabinet/__init__.py
	install -d $(PKG)
	touch $@

$(C_SOURCES): src/cabinet/%.c : $(IFACE)/%.i $(IFACE)/tcmaps.i $(IFACE)/ecode.i
	$(SWIG) $(SWIG_OPTIONS) -python -o $@ -outdir $(SRC)/cabinet $<

clean:
	- rm -rf $(BUILD) dist $(C_SOURCES) test/*.pyc
	
$(BUILD)/test/stamp: $(C_SOURCES) src/cabinet/__init__.py 
	- rm -rf $(BUILD)/test
	- mkdir -p $(BUILD)
	$(PYTHON) setup.py install --install-lib=$(BUILD)/test
	touch $@

test: $(BUILD)/test/stamp
	- PYTHONPATH=$(BUILD)/test $(PYTHON) -m tests.main

bench: scripts/bench.py $(BUILD)/test/stamp
	- rm -rf users.tcb
	- PYTHONPATH=$(BUILD)/test $(PYTHON) scripts/bench.py
	- rm -rf users.tcb

