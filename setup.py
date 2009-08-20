from distutils.core import setup, Extension

setup(name='tokyo',
       version='0.1',
       description='Tokyo Cabinet bindings',
       packages=['tokyo', 'tokyo.cabinet'],
       package_dir={'': 'src'},
       ext_modules=[Extension('tokyo.cabinet._cabext',
                       sources=['src/cabext.cc'],
                       libraries=['tokyocabinet'])]
)
