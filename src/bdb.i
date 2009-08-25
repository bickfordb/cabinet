%module(docstring="The B+ tree database API of Tokyo Cabinet", module="tokyocabinet") bdb
%include "std_string.i"
%include "typemaps.i"
%include "tcmaps.i"
%include "ecode.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tcbdb.h>
#include <string>

class BDBCursor;
class BDB;

class BDB : ECODE {
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

    std::string* get(const std::string & key) {
        int value_size = 0;
        void *value = tcbdbget(_db, key.c_str(), key.length(), &value_size);    
        std::string *result = NULL;
        if (value != NULL) {
            result = new std::string((const char*)value, value_size);
        }
        return result;
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
    TCLIST *fwmkeys(const std::string & prefix, int max=-1) {
        return tcbdbfwmkeys(_db, prefix.c_str(), prefix.length(), max);
    }

    const char * errmsg(long ecode=-1) {
        if (ecode == -1) { 
            ecode = tcbdbecode(_db);
        }
        return tcbdberrmsg(ecode);
    }

    long ecode() { 
        return tcbdbecode(_db);
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

        std::string *key() {
            int sz = 0;
            void *buf = tcbdbcurkey(_cur, &sz);
            std::string *result = buf != NULL ? new std::string((const char*)buf, sz) : NULL;
            free(buf);
            return result;
        }
        std::string *val() {
            int sz = 0;
            void *buf = tcbdbcurval(_cur, &sz);
            std::string *result = buf != NULL ? new std::string((const char*)buf, sz) : NULL;
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

    %pythonappend BDBCursor(BDB *db) "self.__db = args[0]"
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
    %newobject key;
    std::string *key();

    %feature("docstring", "Get the value of the record where the cursor object is.

Returns:
string or None
") value;
    %newobject val;
    std::string *val();

};
    
class BDB : ECODE {
    
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

    %feature("docstring", "Set the tuning parameters of a B+ tree database object.

Note that the tuning parameters should be set before the database is opened.

Arguments
lmemb -- specifies the number of members in each leaf page.  If it is not more than 0, the
   default value is specified.  The default value is 128.
nmemb -- specifies the number of members in each non-leaf page.  If it is not more than 0, the
   default value is specified.  The default value is 256.
bnum --  specifies the number of elements of the bucket array.  If it is not more than 0, the
   default value is specified.  The default value is 32749.  Suggested size of the bucket array
   is about from 1 to 4 times of the number of all pages to be stored.
apow -- specifies the size of record alignment by power of 2.  If it is negative, the default
   value is specified.  The default value is 8 standing for 2^8=256.
fpow -- specifies the maximum number of elements of the free block pool by power of 2.  If it
   is negative, the default value is specified.  The default value is 10 standing for 2^10=1024.
opts -- specifies options by bitwise-or: `BDBTLARGE' specifies that the size of the database
   can be larger than 2GB by using 64-bit bucket array, `BDBTDEFLATE' specifies that each page
   is compressed with Deflate encoding, `BDBTBZIP' specifies that each page is compressed with
   BZIP2 encoding, `BDBTTCBS' specifies that each page is compressed with TCBS encoding.

Returns
If successful, the return value is true, else, it is false.
") tune;
    bool tune(long lmemb, long nmemb,
                     long long bnum, long apow, long fpow, long opts) ;
    
    %feature("docstring", "Set the caching parameters of a B+ tree database object.

Note that the caching parameters should be set before the database is opened. 

Arguments    
lcnum -- specifies the maximum number of leaf nodes to be cached.  If it is not more than 0,
the default value is specified.  The default value is 1024.
ncnum -- specifies the maximum number of non-leaf nodes to be cached.  If it is not more than 0,
the default value is specified.  The default value is 512.

Returns
If successful, the return value is true, else, it is false.
") setcache;
    bool setcache(long lcnum, long ncnum);

    %feature("docstring", "Set the size of the extra mapped memory of a B+ tree database object.

Note that the mapping parameters should be set before the database is opened.

Arguments 
xmsiz -- int, specifies the size of the extra mapped memory.  If it is not more than 0, the extra
mapped memory is disabled.  It is disabled by default.

Returns
If successful, the return value is true, else, it is false.
") setxmsiz;
    bool setxmsiz(long long xmsiz);

    %feature("docstring", "Open a database file and connect a B+ tree database object.

Arguments
path -- str, specifies the path of the database file.
omode -- int, specifies the connection mode: `BDBOWRITER' as a writer, `BDBOREADER' as a reader.
If the mode is `BDBOWRITER', the following may be added by bitwise-or: `BDBOCREAT', which
means it creates a new database if not exist, `BDBOTRUNC', which means it creates a new
database regardless if one exists, `BDBOTSYNC', which means every transaction synchronizes
updated contents with the device.  Both of `BDBOREADER' and `BDBOWRITER' can be added to by
bitwise-or: `BDBONOLCK', which means it opens the database file without file locking, or
`BDBOLCKNB', which means locking is performed without blocking.

Returns
If successful, the return value is true, else, it is false.
") open;
    bool open(const char* path, long omode) ;

    %feature("docstring") close;
    bool close();
    
    %feature("docstring", "Store a new record into a B+ tree database object.

Arguments:
key -- the key
value -- the value

Returns:
boolean") put;
    bool put(const std::string & key, const std::string & value);

    %feature("docstring", "Store a new record into a B+ tree database object.

If a record with the same key exists in the database, this function has no effect. 

Arguments
key -- str, the key
value -- str, the value

Returns
If successful, the return value is true, else, it is false.
") putkeep;
    bool putkeep(const std::string & key, const std::string & value);

    %feature("docstring", "Concatenate a value at the end of the existing record in a B+ tree database object.

If there is no corresponding record, a new record is created. 

Arguments
key -- str, the key
value -- str, the value

Returns
If successful, the return value is true, else, it is false.
") putcat;
    bool putcat(const std::string & key, const std::string & value);
    
    %feature("docstring", "Remove a record of a B+ tree database object.

If the key of duplicated records is specified, the first one is selected.

Arguments
key -- str, the key

Returns
If successful, the return value is true, else, it is false.
") out;
    bool out(const std::string & key) ;

    %feature("docstring", "Retrieve a record in a B+ tree database object.
 
If the key of duplicated records is specified, the first one is selected.  

Arguments
key -- str, the key 

Returns
The value or None
") get;
    %newobject get;
    std::string * get(const std::string & key);
    
    %feature("docstring", "Get the size of the value of a record in a B+ tree
%database object.

If the key of duplicated records is specified, the first one is selected. 

Returns
key -- str, the key

Returns
If successful, the return value is the size of the value of the corresponding record, else,
it is -1.
") vsiz;
    long vsiz(const std::string & key);

    %feature("docstring", "Add an integer to a record in a B+ tree database object.

If the corresponding record exists, the value is treated as an integer and is added to.  If no
record corresponds, a new record of the additional value is stored. 

Arguments
key -- str, specifies the pointer to the region of the key.
num -- int, specifies the additional value.

Returns
If successful, the return value is the summation value, else, it is `INT_MIN'.

") addint;
    long addint(const std::string & key, long num);

    %feature("docstring", "Add a real number to a record in a B+ tree database object.

If the corresponding record exists, the value is treated as a real number and
is added to.  If no record corresponds, a new record of the additional value is
stored. 

Arguments
key -- str, the key
num -- int, the additional value

Returns
If successful, the return value is the summation value, else, it is Not-a-Number.
") adddouble;
    double adddouble(const std::string & key, double num) ;

    %feature("docstring", "Synchronize updated contents of a B+ tree database object with the file and the device.

This function is useful when another process connects to the same database file.

Returns
If successful, the return value is true, else, it is false.
") sync;
    bool sync() ;

    %feature("docstring", "Optimize the file of a B+ tree database object.

This function is useful to reduce the size of the database file with data
fragmentation by successive updating.

Arguments
lmemb -- int, specifies the number of members in each leaf page.  If it is not more than 0, the
current setting is not changed.
nmemb -- int, specifies the number of members in each non-leaf page.  If it is not more than 0, the
current setting is not changed.
bnum -- int, specifies the number of elements of the bucket array.  If it is not more than 0, the
default value is specified.  The default value is two times of the number of pages.
apow -- int, specifies the size of record alignment by power of 2.  If it is negative, the current
setting is not changed.
fpow -- int, specifies the maximum number of elements of the free block pool by power of 2.  If it
is negative, the current setting is not changed.
opts -- int, specifies options by bitwise-or: `BDBTLARGE' specifies that the size of the database
can be larger than 2GB by using 64-bit bucket array, `BDBTDEFLATE' specifies that each record
is compressed with Deflate encoding, `BDBTBZIP' specifies that each page is compressed with
BZIP2 encoding, `BDBTTCBS' specifies that each page is compressed with TCBS encoding.  If it
is `UINT8_MAX', the current setting is not changed.

Returns
If successful, the return value is true, else, it is false.
") optimize;
    bool optimize(TCBDB *bdb, int32_t lmemb, int32_t nmemb,
                   int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts);

    %feature("docstring", "Remove all records of a B+ tree database object.
   `bdb' specifies the B+ tree database object connected as a writer.
   If successful, the return value is true, else, it is false. ") vanish;
    bool vanish();

    %feature("docstring", "Copy the database file of a B+ tree database object.

The database file is assured to be kept synchronized and not modified while the
copying or executing operation is in progress.  So, this function is useful to
create a backup file of the database file. 

Arguments
path -- str, specifies the path of the destination file.  If it begins with `@', the trailing
substring is executed as a command line.

Returns
If successful, the return value is true, else, it is false.  False is returned if the executed
command returns non-zero code.
") copy;
    bool copy(const std::string & path);

    %feature("docstring", "Begin the transaction of a B+ tree database object.

The database is locked by the thread while the transaction so that only one
transaction can be activated with a database object at the same time.  Thus,
the serializable isolation level is assumed if every database operation is
performed in the transaction.  Because all pages are cached on memory while the
transaction, the amount of referred records is limited by the memory capacity.
If the database is closed during transaction, the transaction is aborted
implicitly.

Returns
If successful, the return value is true, else, it is false.
   ") tranbegin;
    bool tranbegin();

    %feature("docstring", "Commit the transaction of a B+ tree database object.

Update in the transaction is fixed when it is committed successfully.

Returns
If successful, the return value is true, else, it is false.
") trancommit;
    bool trancommit();

    %feature("docstring", "Abort the transaction of a B+ tree database object.

Update in the transaction is discarded when it is aborted.  The state of the
database is rollbacked to before transaction.

Returns
If successful, the return value is true, else, it is false.
") tranabort;
    bool tranabort();

    %feature("docstring", "Get the file path of a B+ tree database object.

Returns
The return value is the path of the database file or `NULL' if the object does
not connect to any database file.") path;
    const char *path();

    %feature("docstring", "Get the number of records of a B+ tree database object.

Returns
The return value is the number of records or 0 if the object does not connect
to any database file.") rnum;
    long long rnum();

    %feature("docstring", "Get the size of the database file of a B+ tree database object.

Returns
The return value is the size of the database file or 0 if the object does not connect to any
database file.") fsiz;
    long long fsiz();


    %feature("docstring", "Get forward matching keys in a B+ tree database object.

Arguments
prefix -- str, the key prefix
max -- int, specifies the maximum number of keys to be fetched.  If it is negative, no limit is
specified.

Returns
The return value is a list object of the corresponding keys.  This function does never fail
and return an empty list even if no key corresponds.
") fwmkeys;
    %newobject fwmkeys;
    TCLIST *fwmkeys(const std::string & prefix, int max=-1);

};

%extend BDB { 
    int __len__() { 
        return self->rnum() ;
    }
    
};

%pythoncode %{ 

def cursor(self):
    """Get a cursor for this database"""
    return BDBCursor(self)

def _iter(self):
    """Iterate over all the records in the database."""
    cursor = self.cursor()
    cursor.first()
    yield cursor.key(), cursor.val()
    while cursor.next():
        yield cursor.key(), cursor.val()

def keys(self):
    """Iterate over all the keys in the database"""
    for k, v in self:
        yield k

def values(self): 
    """Iterate over all the values in the database"""
    for k, v in self:
        yield v

def getitem(self, key):
    val = self.get(key)
    if val is None:
        raise KeyError(key)
    return val


BDB.__iter__ = _iter
BDB.items = _iter
BDB.keys = keys
BDB.values = values
BDB.__getitem__ = getitem
BDB.__setitem__ = BDB.put
BDB.cursor = cursor

del cursor
del _iter
del keys
del values
del getitem

%}
