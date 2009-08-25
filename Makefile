
all: 

src/bdb.cc: src/bdb.i src/tcmaps.i
	swig -c++ -I/opt/local/include -modern -python -o src/bdb.cc -outdir src/tokyocabinet src/bdb.i 

src/tdb.cc: src/tdb.i src/tcmaps.i
	swig -c++ -I/opt/local/include -modern -python -o src/tdb.cc -outdir src/tokyocabinet src/tdb.i 

#src/hdb.cc: src/hdb.i src/tcmaps.i
#	swig -c++ -I/opt/local/include -modern -python -o src/hdb.cc -outdir src/tokyocabinet src/hdb.i 

#src/fdb.cc: src/fdb.i src/tcmaps.i
#	swig -c++ -I/opt/local/include -modern -python -o src/fdb.cc -outdir src/tokyocabinet src/fdb.i 

src/adb.cc: src/adb.i src/tcmaps.i
	swig -c++ -I/opt/local/include -modern -python -o src/adb.cc -outdir src/tokyocabinet src/adb.i 

clean:
	- rm -rf build
	- rm -rf src/bdb.cc
	- rm -rf src/adb.cc
	- rm -rf src/tdb.cc
	- rm -rf src/hdb.cc
	- rm -rf src/fdb.cc
	- rm -rf src/tokyocabinet/bdb.py
	- rm -rf src/tokyocabinet/adb.py
	- rm -rf src/tokyocabinet/tdb.py
	- rm -rf src/tokyocabinet/hdb.py
	- rm -rf src/tokyocabinet/fdb.py

test: src/bdb.cc src/tdb.cc src/adb.cc # src/fdb.cc src/hdb.cc 
	- rm -rf build/test
	- mkdir build
	python setup.py install --install-lib=build/test
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.tokyocabinet.bdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.tokyocabinet.tdb
	#- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.tokyocabinet.hdb
	#- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.tokyocabinet.fdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.tokyocabinet.adb

