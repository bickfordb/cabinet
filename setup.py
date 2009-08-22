from distutils.core import setup, Extension

setup(name='tokyocabinet',
       version='0.1',
       description='Tokyo Cabinet bindings',
       packages=['tokyocabinet'],
       package_dir={'': 'src'},
       ext_modules=[Extension('tokyocabinet._bdb',
                       sources=['src/bdb.cc'],
                       libraries=['tokyocabinet'])]
)
