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

all: STAMP
.PHONY: all

STAMP: $(C_SOURCES) $(SRC)/cabinet/__init__.py setup.py
	touch $@

$(C_SOURCES): $(SRC)/cabinet/%.c : $(IFACE)/%.i $(IFACE)/tcmaps.i $(IFACE)/ecode.i
	$(SWIG) $(SWIG_OPTIONS) -python -o $@ -outdir $(SRC)/cabinet $<

clean:
	- rm -rf STAMP $(BUILD) dist $(C_SOURCES) tests/*.pyc src/cabinet/*.py setup.py
.PHONY: clean

$(SRC)/cabinet/__init__.py: $(SRC)/__init__.py.tmpl version.txt
	sed -e s/{{VERSION}}/$$(cat version.txt)/ <$< >$@

setup.py: setup.py.tmpl version.txt
	sed -e s/{{VERSION}}/$$(cat version.txt)/ <$< >$@

$(BUILD)/test/STAMP: STAMP
	- rm -rf $(BUILD)/test
	- mkdir -p $(BUILD)
	$(PYTHON) setup.py install --install-lib=$(BUILD)/test
	touch $@

.PHONY: test
test: $(BUILD)/test/STAMP
	- PYTHONPATH=$(BUILD)/test $(PYTHON) -m tests.main

.PHONY: bench
bench: scripts/bench.py $(BUILD)/test/STAMP
	- rm -rf users.tcb
	- PYTHONPATH=$(BUILD)/test $(PYTHON) scripts/bench.py
	- rm -rf users.tcb

.PHONY: upload
upload: STAMP
	$(PYTHON) setup.py sdist upload

.PHONY: sdist
sdist: STAMP
	$(PYTHON) setup.py sdist

