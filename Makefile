
all: 

src/bdb.cc: src/bdb.i
	swig -c++ -I/opt/local/include -modern -python -o src/bdb.cc -outdir src/tokyocabinet src/bdb.i 

src/tdb.cc: src/tdb.i
	swig -c++ -I/opt/local/include -modern -python -o src/tdb.cc -outdir src/tokyocabinet src/tdb.i 

clean:
	- rm -rf build
	- rm -rf src/bdb.cc
	- rm -rf src/tokyocabinet/bdb.py

test: src/bdb.cc src/bdb.cc src/tdb.cc
	- rm -rf build/test
	- mkdir build
	python setup.py install --install-lib=build/test
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.tokyocabinet.bdb
	- PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.tokyocabinet.tdb

