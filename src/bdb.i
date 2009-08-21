%module(docstring="The B+ tree database API of Tokyo Cabinet", module="tokyo.cabinet") bdb
%include "std_string.i"
%include "typemaps.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tcbdb.h>
#include <string>

class BDBCursor;
class BDB;

class BDB {
    public:
    BDB() { 
        this->_db = tcbdbnew();
    }
    ~BDB() {
        if (this->_db) tcbdbdel(_db);
    }

    bool tune(long lmemb, long nmemb,
                     long long bnum, long apow, long fpow, long opts) {
        return tcbdbtune(_db, lmemb, nmemb, bnum, apow, fpow, opts); 
    }

    bool setcache(long lcnum, long ncnum) {
        return tcbdbsetcache(_db, lcnum, ncnum);
    }

    bool setxmsiz(long long xmsiz) {
        return tcbdbsetxmsiz(_db, xmsiz);
    }

    bool open(const std::string & path, long omode) {
        return tcbdbopen(_db, path.c_str(), omode);
    }
    bool close() {
        return tcbdbclose(_db);
    }

    bool put(const std::string & key, const std::string & value) {
        return tcbdbput(_db, key.c_str(), key.length(), value.c_str(), value.length());
    }

    bool putkeep(const std::string & key, const std::string & value) {
        return tcbdbputkeep(_db, key.c_str(), key.length(), value.c_str(), value.length());
    }

    bool out(const std::string & key) {
        return tcbdbout(_db, key.c_str(), key.length());
    }
    PyObject * get(const std::string & key) {
        int value_size = 0;
        void *value = tcbdbget(_db, key.c_str(), key.length(), &value_size);    
        if (value != NULL) {
            PyObject *result = PyString_FromStringAndSize((const char*) value, value_size);
            free(value);
            return result;
        } else { 
            return Py_None;
        } 
    }
    long vsiz(const std::string & key) { 
        return tcbdbvsiz(_db, key.c_str(), key.length());
    };

    long addint(const std::string & key, long num) {
        return tcbdbaddint(_db, key.c_str(), key.length(), num);
    }
    double adddouble(const std::string & key, double num) {
        return tcbdbadddouble(_db, key.c_str(), key.length(), num);
    }
    bool sync() {
        return tcbdbsync(_db);
    }

    bool optimize(TCBDB *bdb, int32_t lmemb, int32_t nmemb,
                   int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts) {
        return tcbdboptimize(_db, lmemb, nmemb, bnum, apow, fpow, opts);
    }

    bool vanish() {
        return tcbdbvanish(_db);
    }
    bool copy(const std::string & path) {
        return tcbdbcopy(_db, path.c_str());
    }
    bool tranbegin() { 
        return tcbdbtranbegin(_db);
    }

    bool trancommit() {
        return tcbdbtrancommit(_db);
    }
    bool tranabort() { 
        return tcbdbtranabort(_db);
    }

    const char *path() {
        return tcbdbpath(_db);
    }

    long long rnum() { 
        return tcbdbrnum(_db); 
    }

    long long fsiz() {
        return tcbdbfsiz(_db);
    }

    bool putcat(const std::string & key, const std::string & value) {
        return tcbdbputcat(_db, key.c_str(), key.length(), value.c_str(), value.length());
    }
    PyObject *fwmkeys(const std::string & prefix, int max=-1) {
        PyObject *result = Py_None;
        TCLIST *keys = tcbdbfwmkeys(_db, (const char*)prefix.c_str(), prefix.length(), max);
        if (keys != NULL) {
            int num = tclistnum(keys);
            result = PyList_New(num);
            for (int i = 0; i < num; i++) {
                int sz = 0;
                const void *buf = tclistval(keys, i, &sz);
                PyList_SetItem(result, i, PyString_FromStringAndSize((const char*)buf, sz));
            }
        }
        return result;
    }

    static const long TLARGE = 1 << 0;
    static const long TDEFLATE = 1 << 1;
    static const long TBZIP = 1 << 2;
    static const long TTCBS = 1 << 3;
    static const long OREADER = 1 << 0;
    static const long OWRITER = 1 << 1;
    static const long OCREAT = 1 << 2;
    static const long OTRUNC = 1 << 3;
    static const long ONOLCK = 1 << 4;
    static const long OLCKNB = 1 << 5;
    static const long OTSYNC = 1 << 6;

    
    TCBDB *_db; 
};

class BDBCursor { 
    public:
    static const long CPCURRENT = 0;
    static const long CPBEFORE = 1;
    static const long CPAFTER = 2;
        BDBCursor(BDB *bdb) { _cur = tcbdbcurnew(bdb->_db); }
        ~BDBCursor() { tcbdbcurdel(_cur); }

        bool first() { 
            return tcbdbcurfirst(_cur); 
        }
        bool last() {
            return tcbdbcurlast(_cur);
        }
        bool jump(const std::string & key) {
            return tcbdbcurjump(_cur, key.c_str(), key.length());
        }
        bool prev() { return tcbdbcurprev(_cur); }

        bool put(const std::string & value, int cpmode) {
            return tcbdbcurput(_cur,  (const void *)value.c_str(), value.length(), cpmode);
        }

        PyObject *key() {
            int sz = 0;
            void *buf = tcbdbcurkey(_cur, &sz);
            PyObject *result = buf != NULL ? PyString_FromStringAndSize((const char*)buf, sz) : Py_None;
            free(buf);
            return result;
        }
        PyObject *value() {
            int sz = 0;
            void *buf = tcbdbcurval(_cur, &sz);
            PyObject *result = buf != NULL ? PyString_FromStringAndSize((const char*)buf, sz) : Py_None;
            free(buf);
            return result;
        }
        bool next() { 
            return tcbdbcurnext(_cur);
        }
        
        bool out() { 
            return tcbdbcurout(_cur);
        }

    private:
        BDBCUR *_cur;
};
%}

class BDBCursor {
    public:
    static const long CPCURRENT;
    static const long CPBEFORE;
    static const long CPAFTER;

    BDBCursor(BDB *);
    ~BDBCursor();
    %feature("docstring", "Move a cursor object to the first record.
If successful, the return value is true, else, it is false.  False is returned if there is
no record in the database.");
    bool first(); 

    %feature("docstring",  "Move a cursor object to the last record.
If successful, the return value is true, else, it is false.  False is returned if there is
no record in the database.
") last;
    bool last(); 

  %feature("docstring", "Move a cursor object to the front of records corresponding a key.
The cursor is set to the first record corresponding the key or the next substitute if
completely matching record does not exist. 
Arguments:
key -- string, the key to move to
Returns:
If successful, the return value is true, else, it is false.  False is returned if there is
no record corresponding the condition.
") jump;
    bool jump(const std::string & key);


    %feature("docstring", "Move a cursor object to the previous record.

Returns:
If successful, the return value is true, else, it is false.  False is returned if there is
no previous record. 
") prev;
    bool prev();

    %feature("docstring", "
Move a cursor object to the next record.

Returns:
If successful, the return value is true, else, it is false.  False is returned if there is
no next record.
") next;
    bool next();


    %feature("docstring", "Insert a record around a cursor object.

After insertion, the cursor is moved to the inserted record. 

Arguments:
value -- str, the new value
cpmode -- int, specifies detail adjustment: `BDBCPCURRENT', which means that the value of the
   current record is overwritten, `BDBCPBEFORE', which means that the new record is inserted
   before the current record, `BDBCPAFTER', which means that the new record is inserted after the
   current record.
Returns:
If successful, the return value is true, else, it is false.  False is returned when the cursor
is at invalid position.
");
    bool put(const std::string & key, int cpmode);

    %feature("docstring", "Remove the record where a cursor object is.

After deletion, the cursor is moved to the next record if possible. 

Returns:
If successful, the return value is true, else, it is false.  False is returned when the cursor
is at invalid position.
") out; 
    bool out();

    %feature("docstring", "Get the key of the record where the cursor object is.

Returns:
string or None
") key;
    PyObject *key();

    %feature("docstring", "Get the value of the record where the cursor object is.

Returns:
string or None
") value;
    PyObject *value();

};
    
class BDB {
    
    public:
    static const long TLARGE;
    static const long TDEFLATE;
    static const long TBZIP;
    static const long TTCBS;
    static const long OREADER;
    static const long OWRITER;
    static const long OCREAT;
    static const long OTRUNC;
    static const long ONOLCK;
    static const long OLCKNB;
    static const long OTSYNC;

    %feature("autodoc") tune;
    bool tune(long lmemb, long nmemb,
                     long long bnum, long apow, long fpow, long opts) ;
    
    %feature("autodoc") setcache;
    bool setcache(long lcnum, long ncnum);

    %feature("autodoc") setmxsiz;
    bool setxmsiz(long long xmsiz);

    %feature("autodoc") open;
    bool open(const char* path, long omode) ;

    %feature("autodoc") close;
    bool close();
    
    %apply (char *STRING, int LENGTH) { (const void *key, int key_size) };
    %apply (char *STRING, int LENGTH) { (const void *value, int value_size) };

    %feature("docstring", "Store a new record into a B+ tree database object.

Arguments:
key -- the key
value -- the value

Returns:
boolean") put;
    bool put(const std::string & key, const std::string & value);

    %feature("autodoc") putkeep;
    bool putkeep(const std::string & key, const std::string & value);

    %feature("docstring", "Concatenate a value at the end of the existing record in a B+ tree database object.") putcat;
    bool putcat(const std::string & key, const std::string & value);
    
    %feature("autodoc") out;
    bool out(const std::string & key) ;

    %feature("autodoc") get;
    PyObject * get(const std::string & key);
    
    %feature("autodoc") vsiz;
    long vsiz(const std::string & key);

    %feature("autodoc") addint;
    long addint(const std::string & key, long num);

    %feature("autodoc") adddouble;
    double adddouble(const std::string & key, double num) ;

    %feature("autodoc") sync;
    bool sync() ;

    %feature("autodoc") optimize;
    bool optimize(TCBDB *bdb, int32_t lmemb, int32_t nmemb,
                   int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts);

    %feature("autodoc") vanish;
    bool vanish();

    %feature("autodoc") copy;
    bool copy(const std::string & path);

    %feature("autodoc") tranbegin;
    bool tranbegin();

    %feature("autodoc") trancommit;
    bool trancommit();

    %feature("autodoc") tranabort;
    bool tranabort();

    %feature("autodoc") path;
    const char *path();

    %feature("autodoc") rnum;
    long long rnum();

    %feature("autodoc") fsiz;
    long long fsiz();


    %feature("autodoc") fwmkeys;
    PyObject *fwmkeys(const std::string & prefix, int max=-1);

};

%extend BDB { 
    %newobject cursor;
    BDBCursor *cursor() { 
        return new BDBCursor(self);
    }

    int __len__() { 
        return self->rnum() ;
    }
    
};

%pythoncode %{ 
def _iter(self):
    """Iterate over all the records in the database."""
    cursor = self.cursor()
    cursor.first()
    yield cursor.key(), cursor.value()
    while cursor.next():
        yield cursor.key(), cursor.value()

def _keys(self):
    """Iterate over all the keys in the database"""
    for k, v in self:
        yield k

def _values(self): 
    """Iterate over all the values in the database"""
    for k, v in self:
        yield v

def _getitem(self, key):
    val = self.get(key)
    if val is None:
        raise KeyError(key)
    return val


BDB.__iter__ = _iter
BDB.items = _iter
BDB.keys = _keys
BDB.values = _values
BDB.__getitem__ = _getitem
BDB.__setitem__ = BDB.put

del _iter
del _keys
del _values
del _getitem

%}
