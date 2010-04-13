
import os
import shutil
import tempfile
import time
import unittest

from cabinet import fdb

def assert_eq(left, right, msg="expected %(left)r == %(right)r"):
    if left != right:
        raise AssertionError(msg % locals())

class FDBTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.db = fdb.FDB() 
        self.db.open(self.dir + '/fdb.tcb', fdb.FDB.OCREAT | fdb.FDB.OWRITER | fdb.FDB.OREADER | fdb.FDB.OTRUNC)

    def test_vanish(self):
        assert self.db.vanish()

    def test_copy(self):
        assert self.db.copy(self.dir + '/foo.tcb')

    def test_close(self):
        assert self.db.close()

    def test_vsiz(self):
        assert self.db.put(1, 'Brandon')
        assert_eq(self.db.get(1), 'Brandon')
        assert_eq(self.db.vsiz(1), 7)

    def test_put(self):
        assert self.db.put(1, 'b')
        assert_eq(self.db.get(1), 'b')

    def test_putkeep(self):
        assert self.db.put(1, 'b')
        assert not self.db.putkeep(1, 'c')
        assert_eq(self.db.get(1), 'b')

    def test_putcat(self):
        assert self.db.put(1, 'b')
        assert self.db.putcat(1, 'c')
        assert_eq(self.db.get(1), 'bc')


    def test_out(self):
        assert self.db.put(1, 'b')
        assert self.db.out(1)
        assert_eq(self.db.get(1), None)


    def test_putasync(self):
        assert self.db.put(1, 'b')
        assert_eq(self.db.get(1), 'b')

    def test_iter(self):
        assert_eq(list(self.db.items()), [])
        assert self.db.put(1, 'b')
        assert_eq(list(self.db.items()), [(1, 'b')])

    def test_addint(self):
        assert_eq(self.db.addint(1, 0), 0)
        assert_eq(self.db.addint(1, 1), 1)
        assert_eq(self.db.addint(1, 1), 2)

    def test_adddouble(self):
        assert_eq(self.db.adddouble(1, 0), 0)
        assert_eq(self.db.adddouble(1, 1.1), 1.1)
        assert_eq(self.db.adddouble(2, -2.0), -2.0)

    def test_sync(self):
        assert self.db.sync()

    def tearDown(self):
        self.db.close()
        shutil.rmtree(self.dir, ignore_errors=True)

    def test_items(self):
        self.db.put(1, 'x')
        self.db.put(2, 'y')
        assert_eq(set(self.db.items()), set([(1, 'x'), (2, 'y')]))

    def test_keys(self):
        self.db.put(1, 'x')
        self.db.put(2, 'y')
        assert_eq(set(self.db.keys()), set([1, 2]))
        assert_eq(set(self.db), set([1, 2]))

    def test_values(self):
        self.db.put(1, 'x')
        self.db.put(2, 'y')
        assert_eq(set(self.db.values()), set(['x', 'y']))

if __name__ == '__main__':
    unittest.main()

