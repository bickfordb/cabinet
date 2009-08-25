import os
import shutil
import tempfile
import time
import unittest

from tokyocabinet import adb

def assert_eq(left, right, msg="expected %(left)r == %(right)r"):
    if left != right:
        raise AssertionError(msg % locals())

class ADBTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.db = adb.ADB() 
        self.db.open(self.dir + '/adb.tcb#mode=crw')

    def test(self):
        assert_eq(len(self.db), 0)
        self.db['foo'] = 'bar'
        assert_eq(len(self.db), 1)
        assert_eq(list(self.db.items()), [('foo', 'bar')])

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

    def test_misc(self):
        assert_eq(self.db.get('a'), None)
        result = self.db.misc("putcat", ['a', 'x'])
        assert_eq(self.db.get('a'), 'x')
        result = self.db.misc("putcat", ['a', 'w'])
        assert_eq(self.db.get('a'), 'xw')

    def tearDown(self):
        shutil.rmtree(self.dir, ignore_errors=True)

if __name__ == '__main__':
    unittest.main()

