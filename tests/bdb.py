import os
import shutil
import tempfile
import time
import unittest

from cabinet import bdb

def assert_eq(left, right, msg="expected %(left)r == %(right)r"):
    if left != right:
        raise AssertionError(msg % locals())

class BDBTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.db = bdb.BDB() 
        self.db.open(self.dir + '/bdb.db', bdb.BDB.OCREAT | bdb.BDB.OREADER | bdb.BDB.OWRITER)

    def test_bench(self):
        for i in range(10000):
            self.db[os.urandom(8).encode('hex')] = os.urandom(128).encode('hex')
        self.db.sync()

    def test_putkeep(self):
        self.db.putkeep('foo', 'bar')

    def test_putcat(self):
        self.db.putcat('foo', 'bar')

    def test_path(self):
        assert self.db.path()

    def test_len(self):
        self.db['foo'] = 'bar'
        assert self.db.rnum() == 1

    def test_fsiz(self):
        self.db['foo'] = 'bar'
        assert self.db.fsiz() > 0

    def test_txn(self):
        self.db.tranbegin()
        self.db['foo'] = 'bar'
        self.db.tranabort()
        assert_eq(self.db.get('foo'), None)
        self.db.tranbegin()
        self.db['foo'] = 'bar'
        self.db.trancommit()
        assert_eq(self.db['foo'], 'bar')

    def test_cursor(self):
        self.db.put('foo', 'bar')
        cursor = self.db.cursor()
        cursor.first()
        assert_eq(cursor.key(), "foo")
        assert_eq(cursor.val(), "bar")

    def test_put_get(self):
        self.db.put('foo', 'bar')
        result = self.db.get('foo')
        assert result == 'bar'

    def test_fwmkeys(self):
        self.db.put('foo', 'bar')
        self.db.put('kafka', 'franz')
        assert self.db.fwmkeys('f') == ['foo'], db.fwmkeys('f')
        assert self.db.fwmkeys('k') == ['kafka'], db.fwmkeys('k')

    def test_len(self):
        self.db.put('foo', 'bar')
        assert len(self.db) == 1

    def test_iter(self):
        self.db.put('foo', 'bar')
        assert_eq(list(self.db), [('foo', 'bar')])
        assert_eq(list(self.db.keys()), ['foo'])
        assert_eq(list(self.db.values()), ['bar'])

    def tearDown(self):
        shutil.rmtree(self.dir, ignore_errors=True)

if __name__ == '__main__':
    unittest.main()

