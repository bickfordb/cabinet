import os
import shutil
import tempfile
import time
import unittest

from tokyocabinet import tdb

def assert_eq(left, right, msg="expected %(left)r == %(right)r"):
    if left != right:
        raise AssertionError(msg % locals())

class TDBTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.db = tdb.TDB() 
        self.db.open(self.dir + '/tdb.db', tdb.TDB.OCREAT | tdb.TDB.OREADER | tdb.TDB.OWRITER)

    def test_putkeep(self):
        self.db.putkeep('foo', 'bar')

    def test_putcat(self):
        self.db.putcat('foo', 'bar')

    def test_path(self):
        assert self.db.path()

    def test_len(self):
        self.db['foo'] = 'bar'
        assert self.db.rnum() == 1

    def test_len(self):
        self.db.put('foo', 'bar')
        assert len(self.db) == 1

    def tearDown(self):
        shutil.rmtree(self.dir, ignore_errors=True)

if __name__ == '__main__':
    unittest.main()
