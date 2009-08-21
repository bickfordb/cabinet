import shutil
import unittest
import tempfile

from tokyo.cabinet import bdb

class BDBTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()

    def test(self):
        db = bdb.BDB() 
        #print db
        #print self.dir
        db.open(self.dir + '/bdb.db', db.OCREAT | db.OREADER | db.OWRITER)
        db.put('foo', 'bar')
        result = db.get('foo')
        assert result == 'bar'
        del db

    def tearDown(self):
        shutil.rmtree(self.dir, ignore_errors=True)

if __name__ == '__main__':
    unittest.main()

