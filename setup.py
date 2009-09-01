from distutils.core import setup, Extension

setup(name='cabinet',
       version='1.0',
       description='Tokyo Cabinet bindings',
       packages=['cabinet'],
       package_dir={'': 'src'},
       ext_modules=[
           Extension('cabinet._bdb',
               sources=['src/bdb.cc'],
               libraries=['tokyocabinet']),
           Extension('cabinet._adb',
               sources=['src/adb.cc'],
               libraries=['tokyocabinet']),
           Extension('cabinet._fdb',
               sources=['src/fdb.cc'],
               libraries=['tokyocabinet']),
           Extension('cabinet._hdb',
               sources=['src/hdb.cc'],
               libraries=['tokyocabinet']),
            Extension('cabinet._tdb',
               sources=['src/tdb.cc'],
               libraries=['tokyocabinet'])])

