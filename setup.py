from distutils.core import setup, Extension

setup(name='cabinet',
       version='1.0.1',
       description='Tokyo Cabinet IDL compatible bindings',
       long_description='''Tokyo Cabinet IDL compatible bindings

Compatibility note: This binding targets the Tokyo Cabinet 1.4.32 and will not work with earlier Tokyo Cabinet releases that are in a number of distributions.

Tokyo Cabinet website: http://tokyocabinet.sourceforge.net/

Tokyo Cabinet is a library of routines for managing a database. The database is a simple data file containing records, each is a pair of a key and a value. Every key and value is serial bytes with variable length. Both binary data and character string can be used as a key and a value. There is neither concept of data tables nor data types. Records are organized in hash table, B+ tree, or fixed-length array.

Tokyo Cabinet is developed as the successor of GDBM and QDBM on the following purposes. They are achieved and Tokyo Cabinet replaces conventional DBM products.
''',
       author='Brandon Bickford',
       author_email='bickfordb@gmail.com',
       license='LGPL',
       packages=['cabinet'],
       url='http://github.com/bickfordb/tokyo/',
       package_dir={'': 'src'},
       classifiers=[
           'License :: OSI Approved :: GNU Library or Lesser General Public License (LGPL)', 
           'Topic :: Database',
       ],
       ext_modules=[
           Extension('cabinet._bdb',
               sources=['src/bdb.c'],
               libraries=['tokyocabinet']),
           Extension('cabinet._adb',
               sources=['src/adb.c'],
               libraries=['tokyocabinet']),
           Extension('cabinet._fdb',
               sources=['src/fdb.c'],
               libraries=['tokyocabinet']),
           Extension('cabinet._hdb',
               sources=['src/hdb.c'],
               libraries=['tokyocabinet']),
            Extension('cabinet._tdb',
               sources=['src/tdb.c'],
               libraries=['tokyocabinet'])])

