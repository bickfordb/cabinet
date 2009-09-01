
all: 

src/bdb.cc: src/bdb.i src/tcmaps.i src/ecode.i
	swig -c++ -I/opt/local/include -modern -python -o src/bdb.cc -outdir src/cabinet src/bdb.i 

src/tdb.cc: src/tdb.i src/tcmaps.i src/ecode.i
	swig -c++ -I/opt/local/include -modern -python -o src/tdb.cc -outdir src/cabinet src/tdb.i 

src/hdb.cc: src/hdb.i src/tcmaps.i src/ecode.i
	swig -c++ -I/opt/local/include -modern -python -o src/hdb.cc -outdir src/cabinet src/hdb.i 

src/fdb.cc: src/fdb.i src/tcmaps.i src/ecode.i
	swig -c++ -I/opt/local/include -modern -python -o src/fdb.cc -outdir src/cabinet src/fdb.i 

src/adb.cc: src/adb.i src/tcmaps.i src/ecode.i
	swig -c++ -I/opt/local/include -modern -python -o src/adb.cc -outdir src/cabinet src/adb.i 

clean:
	- rm -rf build
	- rm -rf src/bdb.cc
	- rm -rf src/adb.cc
	- rm -rf src/tdb.cc
	- rm -rf src/hdb.cc
	- rm -rf src/fdb.cc
	- rm -rf src/cabinet/bdb.py
	- rm -rf src/cabinet/adb.py
	- rm -rf src/cabinet/tdb.py
	- rm -rf src/cabinet/hdb.py
	- rm -rf src/cabinet/fdb.py

test: src/bdb.cc src/tdb.cc src/adb.cc src/hdb.cc src/fdb.cc
	- rm -rf build/test
	- mkdir build
	python setup.py install --install-lib=build/test
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.bdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.tdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.hdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.fdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.cabinet.adb

