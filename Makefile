
all: src/bdb.cc

src/bdb.cc: src/bdb.i
	swig -c++ -I/opt/local/include -modern -python -o src/bdb.cc -outdir src/tokyo/cabinet src/bdb.i 

clean:
	- rm -rf build
	- rm -rf src/bdb.cc
	- rm -rf src/tokyo/cabinet/bdb.py

test: src/bdb.cc
	python setup.py build 
	python setup.py install --root=tests/lib
