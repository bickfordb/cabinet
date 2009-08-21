import shutil
import unittest
import tempfile

from tokyo.cabinet import bdb

def assert_eq(left, right, msg="expected %(left)r == %(right)r"):
    if left != right:
        raise AssertionError(msg % locals())

class BDBTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.db = bdb.BDB() 
        self.db.open(self.dir + '/bdb.db', bdb.BDB.OCREAT | bdb.BDB.OREADER | bdb.BDB.OWRITER)

    def test_cursor(self):
        self.db.put('foo', 'bar')
        cursor = self.db.cursor()
        cursor.first()
        assert_eq(cursor.key(), "foo")
        assert_eq(cursor.value(), "bar")

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

