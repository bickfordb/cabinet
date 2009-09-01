
import os
import shutil
import tempfile
import time
import unittest

from tokyocabinet import hdb

def assert_eq(left, right, msg="expected %(left)r == %(right)r"):
    if left != right:
        raise AssertionError(msg % locals())

class HDBTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.db = hdb.HDB() 
        self.db.open(self.dir + '/hdb.tcb', hdb.HDB.OCREAT | hdb.HDB.OWRITER | hdb.HDB.OREADER)

    def test_vanish(self):
        self.db.vanish()

    def test_copy(self):
        self.db.copy(self.dir + '/foo.tcb')

    def test_close(self):
        assert self.db.close()

    def test_put(self):
        assert self.db.put('a', 'b')
        assert_eq(self.db.get('a'), 'b')

    def test_putkeep(self):
        assert self.db.put('a', 'b')
        assert not self.db.putkeep('a', 'c')
        assert_eq(self.db.get('a'), 'b')

    def test_putcat(self):
        assert self.db.put('a', 'b')
        assert self.db.putcat('a', 'c')
        assert_eq(self.db.get('a'), 'bc')

    def test_out(self):
        self.db.put('a', 'b')
        self.db.out('a')
        assert_eq(self.db.get('a'), None)

    def test_vsiz(self):
        self.db.put('a', 'b')
        assert_eq(self.db.vsiz('a'), 1)

    def test_putasync(self):
        self.db.put('a', 'b')
        assert_eq(self.db.get('a'), 'b')

    def test_iter(self):
        assert_eq(list(self.db.items()), [])
        assert self.db.put('a', 'b')
        assert_eq(list(self.db.items()), [('a', 'b')])

    def test_fwmkeys(self):
        assert self.db.put('xa', '1')
        assert self.db.put('xb', '2')
        assert_eq(self.db.fwmkeys('y'), [])
        assert_eq(self.db.fwmkeys('x'), ['xa', 'xb'])
        assert_eq(self.db.fwmkeys('x', 1), ['xa'])
        assert_eq(self.db.fwmkeys('xa'), ['xa'])

    def test_addint(self):
        assert_eq(self.db.addint('x', 0), 0)
        assert_eq(self.db.addint('x', 1), 1)
        assert_eq(self.db.addint('x', 1), 2)

    def test_adddouble(self):
        assert_eq(self.db.adddouble('x', 0), 0)
        assert_eq(self.db.adddouble('x', 1.1), 1.1)
        assert_eq(self.db.adddouble('y', -2.0), -2.0)

    def test_sync(self):
        assert self.db.sync()

    def tearDown(self):
        shutil.rmtree(self.dir, ignore_errors=True)

if __name__ == '__main__':
    unittest.main()

