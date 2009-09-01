import os
import shutil
import tempfile
import time
import unittest

from cabinet import tdb

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

    def test_putcat(self):
        assert self.db.put('y', {'gender': 'm'})
        assert self.db.putcat('y', {'name': 'Brandon'})
        assert_eq(self.db.get('y'), {'name': 'Brandon', 'gender': 'm'})

    def test_putkeep(self):
        self.db.putkeep('y', {'name': 'Brandon', 'gender': 'm'})
        self.db.putkeep('y', {'name': 'Other Brandon', 'gender': 'm'})
        assert_eq(self.db.get('y'), {'name': 'Brandon', 'gender': 'm'})

    def test_setindex(self):
        db = tdb.TDB() 
        db.setindex('name', tdb.TDB.ITLEXICAL | tdb.TDB.ITOPT)
        db.open(self.dir + '/tdb-setindex.db', tdb.TDB.OCREAT | tdb.TDB.OREADER | tdb.TDB.OWRITER)
        db.put('a', {'name': 'Brandon', 'gender': 'm', 'age': '29'})

    def test_len(self):
        assert self.db.rnum() == 0
        assert len(self.db) == 0
        self.db.putcat('y', {'name': 'Brandon', 'gender': 'm'})
        assert self.db.rnum() == 1
        assert len(self.db) == 1

    def test_query(self):
        self.db.putcat('a', {'name': 'Joyce', 'gender': 'f'})
        self.db.putcat('b', {'name': 'Brandon', 'gender': 'm'})
        self.db.putcat('c', {'name': 'Rufus', 'gender': 'm'})

        q = tdb.TDBQuery(self.db)
        assert_eq(q.search(), ['a', 'b', 'c'])
        q.addcond('gender', q.QCSTREQ, 'm')
        assert_eq(q.search(), ['b', 'c'])
        q.addcond('name', q.QCSTREQ, 'Brandon')
        assert_eq(q.search(), ['b'])

    def test_multisearch(self): 
        self.db.putcat('a', {'name': 'Joyce', 'gender': 'f'})
        self.db.putcat('b', {'name': 'Brandon', 'gender': 'm'})
        self.db.putcat('c', {'name': 'Rufus', 'gender': 'm'})
        q1 = tdb.TDBQuery(self.db)
        q2 = tdb.TDBQuery(self.db)
        q1.addcond('name', q1.QCSTREQ, 'Brandon')
        q2.addcond('gender', q1.QCSTREQ, 'm')
    
        assert_eq(q1.metasearch([q2], q1.MSISECT), 
                set(['b']))

        assert_eq(q1.metasearch([], q1.MSISECT), set())

    def test_dbref(self): 
        db = tdb.TDB() 
        db.open(self.dir + '/tdb-ex.db', tdb.TDB.OCREAT | tdb.TDB.OREADER | tdb.TDB.OWRITER)
        db.putcat('b', {'name': 'Brandon', 'car': 'fast'})
        query = tdb.TDBQuery(db)
        del db
        result = query.search()
        assert_eq(result, ['b'])
        del query

    def tearDown(self):
        self.db.close()
        shutil.rmtree(self.dir, ignore_errors=True)

if __name__ == '__main__':
    unittest.main()

