import unittest

from tokyo.cabinet import cabext

class BDBTest(unittest.TestCase):
    def test(self):
        bdb = cabext.BDB() 
        print bdb
        del bdb

if __name__ == '__main__':
    unittest.main()

