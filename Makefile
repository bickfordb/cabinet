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

all: $(C_SOURCES) $(SRC)/cabinet/__init__.py setup.py
.PHONY: all	

$(C_SOURCES): $(SRC)/cabinet/%.c : $(IFACE)/%.i $(IFACE)/tcmaps.i $(IFACE)/ecode.i
	$(SWIG) $(SWIG_OPTIONS) -python -o $@ -outdir $(SRC)/cabinet $<

clean:
	- rm -rf $(BUILD) dist $(C_SOURCES) test/*.pyc src/cabinet/*.py setup.py 
.PHONY: clean
	
$(SRC)/cabinet/__init__.py: $(SRC)/__init__.py.tmpl version.txt
	sed -e s/{{VERSION}}/$$(cat version.txt)/ <$< >$@

setup.py: setup.py.tmpl version.txt
	sed -e s/{{VERSION}}/$$(cat version.txt)/ <$< >$@

$(BUILD)/test/stamp: $(C_SOURCES) $(SRC)/cabinet/__init__.py 
	- rm -rf $(BUILD)/test
	- mkdir -p $(BUILD)
	$(PYTHON) setup.py install --install-lib=$(BUILD)/test
	touch $@

test: $(BUILD)/test/stamp
	- PYTHONPATH=$(BUILD)/test $(PYTHON) -m tests.main
.PHONY: test

bench: scripts/bench.py $(BUILD)/test/stamp
	- rm -rf users.tcb
	- PYTHONPATH=$(BUILD)/test $(PYTHON) scripts/bench.py
	- rm -rf users.tcb
.PHONY: bench

