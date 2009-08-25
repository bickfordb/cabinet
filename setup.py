from distutils.core import setup, Extension

setup(name='tokyocabinet',
       version='0.1',
       description='Tokyo Cabinet bindings',
       packages=['tokyocabinet'],
       package_dir={'': 'src'},
       ext_modules=[
           Extension('tokyocabinet._bdb',
               sources=['src/bdb.cc'],
               libraries=['tokyocabinet']),
           Extension('tokyocabinet._adb',
               sources=['src/adb.cc'],
               libraries=['tokyocabinet']),
           Extension('tokyocabinet._fdb',
               sources=['src/fdb.cc'],
               libraries=['tokyocabinet']),
           Extension('tokyocabinet._hdb',
               sources=['src/hdb.cc'],
               libraries=['tokyocabinet']),
            Extension('tokyocabinet._tdb',
               sources=['src/tdb.cc'],
               libraries=['tokyocabinet'])])

