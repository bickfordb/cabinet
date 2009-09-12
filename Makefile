
c_output = src/bdb.c src/tdb.c
cpp_output = src/adb.cc src/hdb.cc src/fdb.cc 
py_output = src/cabinet/adb.py src/cabinet/bdb.py src/cabinet/fdb.py src/cabinet/hdb.py

deps = src/bdb.i src/tdb.i src/fdb.i src/adb.i src/fdb.i src/tcmaps.i src/ecode.i src/cabinet/__init__.py

all: $(c_output) $(cpp_output) src/cabinet/__init__.py src/cabinet

src/cabinet/__init__.py:
	- touch src/cabinet/__init__.py

$(c_output): src/%.c : src/%.i src/tcmaps.i src/ecode.i 
	swig -I/opt/local/include -modern -python -o $@ -outdir src/cabinet $<

$(cpp_output): src/%.cc : src/%.i src/tcmaps.i src/ecode.i 
	swig -c++ -I/opt/local/include -modern -python -o $@ -outdir src/cabinet $<

clean:
	- rm -rf build dist $(c_output) $(cpp_output) $(py_output) src/cabinet/*.py
	
build/test: $(c_output) $(cpp_output) $(deps)
	- rm -rf build/test
	- mkdir build
	python setup.py install --install-lib=build/test
	
test: build/test
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.bdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.tdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.hdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.fdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.adb
	rm -rf build/test

bench: build/test
	PYTHONPATH=build/test python -m bench

tb: build/test
	PYTHONPATH=build/test python -m tb

