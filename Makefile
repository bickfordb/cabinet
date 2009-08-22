
all: src/bdb.cc

src/bdb.cc: src/bdb.i
	swig -c++ -I/opt/local/include -modern -python -o src/bdb.cc -outdir src/tokyocabinet src/bdb.i 

clean:
	- rm -rf build
	- rm -rf src/bdb.cc
	- rm -rf src/tokyocabinet/bdb.py

test: src/bdb.cc
	- rm -rf build/test
	- mkdir build
	python setup.py install --install-lib=build/test
	PYTHONPATH="build/test:$(PYTHONPATH)" python -m tests.tokyocabinet.bdb -v

