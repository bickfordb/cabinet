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

    def test_path(self):
        assert self.db.path()

    def test_put(self):
        self.db.put('y', {'name': 'Brandon', 'gender': 'm'})
        assert_eq(self.db.get('y'), {'name': 'Brandon', 'gender': 'm'})

    def test_len(self):
        assert self.db.rnum() == 0
        assert len(self.db) == 0

    def tearDown(self):
        shutil.rmtree(self.dir, ignore_errors=True)

if __name__ == '__main__':
    unittest.main()

