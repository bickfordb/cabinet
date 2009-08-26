%module(docstring="The table database API of Tokyo Cabinet", module="tokyocabinet") tdb
%include "std_string.i"
%include "tcmaps.i"
%include "typemaps.i"
%include "ecode.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tctdb.h>
#include <string>

using namespace std;

class TDB : ECODE {
    public:
    TDB() { 
        _db = tctdbnew();
    }
    ~TDB() {
        if (_db != NULL) tctdbdel(_db);
    }

    long ecode() { return tctdbecode(_db); }

    const char * errmsg(long ecode=-1) { 
        if (ecode == -1) 
            ecode = tctdbecode(_db);
        return tctdberrmsg(ecode);
    }

    TCTDB *_db; 
};

class TDBQuery {
    public:
    TDBQuery(TDB *db) {
        _q = tctdbqrynew(db->_db);
    }
    ~TDBQuery() {
        if (_q != NULL) 
            tctdbqrydel(_q);
    }
    TDBQRY *_q;
};
%}

class TDB : ECODE {
};

%extend TDB { 
    %feature("docstring", "Get the number of rows in the database") __len__;
    int __len__() { 
        return tctdbrnum(self->_db);
    }

    %feature("docstring", "Set the tuning parameters of a table database object.

Note that the tuning parameters should be set before the database is opened.

Arguments

bnum -- specifies the number of elements of the bucket array.  If it is not more than 0, the
default value is specified.  The default value is 131071.  Suggested size of the bucket array
is about from 0.5 to 4 times of the number of all records to be stored.
apow -- specifies the size of record alignment by power of 2.  If it is negative, the default
value is specified.  The default value is 4 standing for 2^4=16.
fpow -- specifies the maximum number of elements of the free block pool by power of 2.  If it
is negative, the default value is specified.  The default value is 10 standing for 2^10=1024.
opts -- specifies options by bitwise-or: `TDBTLARGE' specifies that the size of the database
can be larger than 2GB by using 64-bit bucket array, `TDBTDEFLATE' specifies that each record
is compressed with Deflate encoding, `TDBTBZIP' specifies that each record is compressed with
BZIP2 encoding, `TDBTTCBS' specifies that each record is compressed with TCBS encoding.

Returns
If successful, the return value is true, else, it is false.
") tune;
    bool tune(int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts) {
        return tctdbtune(self->_db, bnum, apow, fpow, opts); 
    }
    
    %feature ("docstring", "Set the caching parameters of a table database object.

Note that the caching parameters should be set before the database is opened.  Leaf nodes and
non-leaf nodes are used in column indexes.

Arguments
rcnum -- specifies the maximum number of records to be cached.  If it is not more than 0, the
record cache is disabled.  It is disabled by default.
lcnum -- specifies the maximum number of leaf nodes to be cached.  If it is not more than 0,
the default value is specified.  The default value is 2048.
ncnum -- specifies the maximum number of non-leaf nodes to be cached.  If it is not more than 0,
the default value is specified.  The default value is 512.

Returns
If successful, the return value is true, else, it is false.
") setcache;
    bool setcache(int32_t rcnum, int32_t lcnum, int32_t ncnum) {
        return tctdbsetcache(self->_db, rcnum, lcnum, ncnum);
    }

    %feature("docstring", "Set the size of the extra mapped memory of a table database object.

Note that the mapping parameters should be set before the database is opened. 

Arguments
xmsiz -- specifies the size of the extra mapped memory.  If it is not more than 0, the extra
mapped memory is disabled.  The default size is 67108864.

Returns
If successful, the return value is true, else, it is false.
   ") setxmsiz;
    bool setxmsiz(long long xmsiz) {
        return tctdbsetxmsiz(self->_db, xmsiz);
    }

    %feature("docstring", "Open a database file and connect a table database object.

Arguments
path -- specifies the path of the database file.
omode -- specifies the connection mode: `TDBOWRITER' as a writer, `TDBOREADER' as a reader.
If the mode is `TDBOWRITER', the following may be added by bitwise-or: `TDBOCREAT', which
means it creates a new database if not exist, `TDBOTRUNC', which means it creates a new
database regardless if one exists, `TDBOTSYNC', which means every transaction synchronizes
updated contents with the device.  Both of `TDBOREADER' and `TDBOWRITER' can be added to by
bitwise-or: `TDBONOLCK', which means it opens the database file without file locking, or
`TDBOLCKNB', which means locking is performed without blocking.

Returns
If successful, the return value is true, else, it is false.
") open;
    bool open(const std::string & path, long omode) {
        return tctdbopen(self->_db, path.c_str(), omode);
    }

    %feature("docstring", "") close;
    bool close() {
        return tctdbclose(self->_db);
    }

    %feature("docstring", "Store a record into a table database object.

If a record with the same key exists in the database, it is overwritten.

Arguments
key -- str, the primary key
cols -- dict{str:str}, a dictionary of string (column) to string (value)

Returns
If successful, the return value is true, else, it is false.
") put;
    bool put(const std::string & key, TCMAP *columns) {
        return tctdbput(self->_db, key.c_str(), key.length(), columns);
    }

    %feature("docstring", "Retrieve a record in a table database object.

Arguments
key -- str, the primary key

Returns
If successful, the return value is a map object of the columns of the corresponding record.
None is returned if no record corresponds.
") get;
    %newobject get;
    TCMAP *get(const std::string & key) {
        return tctdbget(self->_db, key.c_str(), key.length());
    }
    %feature("docstring", "Get the file path of a table database object.

Returns
The return value is the path of the database file or `NULL' if the object does
not connect to any database file.") path;
    const char *path() {
        return tctdbpath(self->_db);
    }

    %feature("docstring", "Get the number of records in the database") rnum;
    long long rnum() { 
        return tctdbrnum(self->_db); 
    }

    
    %feature("docstring", "Get the size of the database file of a table database object.

Returns
The return value is the size of the database file or 0 if the object does not
connect to any database file. ") fsiz;
    long long fsiz() {
        return tctdbfsiz(self->_db);
    }

    %feature("docstring", "Store a new record into a table database object.

If a record with the same key exists in the database, this function has no effect.

Arguments
key -- str, the primary key
cols -- dict, the columns / values

Returns
If successful, the return value is true, else, it is false.
") putkeep;
    bool putkeep(const std::string & pk, TCMAP *cols) { 
        return tctdbputkeep(self->_db, pk.c_str(), pk.length(), cols);
    }

    %feature("docstring", "Concatenate columns of the existing record in a table database object.

If there is no corresponding record, a new record is created. 

Arguments
key -- str, the primary key
cols -- dict, the columns / values to set

Returns
If successful, the return value is true, else, it is false.
") putcat;
    bool putcat(const std::string & pk, TCMAP *cols) {
        return tctdbputcat(self->_db, pk.c_str(), pk.length(), cols);
   } 

   %feature("docstring" , "Remove a record of a table database object.

Arguments
key -- str, the primary key

Returns
If successful, the return value is true, else, it is false. 
") out;
    bool out(const std::string & pk) { 
        return tctdbout(self->_db, pk.c_str(), pk.length());
    }

    %feature("docstring", "Get the size of the value of a record in a table database object.

Arguments
pk -- str, the primary key

Returns
If successful, the return value is the size of the value of the corresponding
record, else, it is -1.") vsiz;
    int vsiz(const std::string & pk) { 
        return tctdbvsiz(self->_db, pk.c_str(), pk.length());
    }
    %feature("docstring", "Initialize the iterator of a table database object.

   The iterator is used in order to access the primary key of every record stored in a
   database.

   Returns
   If successful, the return value is true, else, it is false.
    ") iterinit;
    bool iterinit () {
        return tctdbiterinit(self->_db);
    }

    %feature("docstring", "Get the next primary key of the iterator of a table database object.

It is possible to access every record by iteration of calling this function.
It is allowed to update or remove records whose keys are fetched while the iteration.
However, it is not assured if updating the database is occurred while the iteration.  Besides,
the order of this traversal access method is arbitrary, so it is not assured that the order of
storing matches the one of the traversal access.

Returns
The next primary key or None
") iternext;
    %newobject iternext;
    std::string *iternext() {
        int sp;
        void *buf = tctdbiternext(self->_db, &sp);
        if (buf != NULL) { 
            return new std::string((const char*)buf, sp); 
        } else { 
            return NULL;
        }
    }
    
    %feature("docstring", "Get forward matching primary keys in a table database object.


Note that this function may be very slow because every key in the database is scanned.

Arguments
prefix -- str, the primary key prefix
max -- specifies the maximum number of keys to be fetched.  If it is negative, no limit is
specified.

Returns
The return value is a list object of the corresponding keys.  This function does never fail
and return an empty list even if no key corresponds.
") fwmkeys;
    %newobject fwmkeys;
    TCLIST *fwmkeys(const std::string & pk, int max=-1) {
        return tctdbfwmkeys(self->_db, pk.c_str(), pk.length(), max);
    }

    %feature("docstring", "Add an integer to a column of a record in a table database object.

If successful, the return value is the summation value, else, it is `INT_MIN'.
The additional value is stored as a decimal string value of a column whose name
is '_num'.  If no record corresponds, a new record with the additional value is
stored.

Arguments 
key -- str, the primary key
num -- int, the number to add
    ") addint;
    int addint(const std::string & key, int num) {
        return tctdbaddint(self->_db, key.c_str(), key.length(), num);
    }
    %feature("docstring", "Add a real number to a column of a record in a table database object.

If successful, the return value is the summation value, else, it is
Not-a-Number.  The additional value is stored as a decimal string value of a
column whose name is '_num'.  If no record corresponds, a new record with the
additional value is stored. 

Arguments
key -- str, the primary key
num -- float, the number to add
") adddouble;   
    double adddouble(const std::string & key, double num) {
        return tctdbadddouble(self->_db, key.c_str(), key.length(), num);
    }
        
    %feature("docstring", "Synchronize updated contents of a table database object with the file and the device.

If successful, the return value is true, else, it is false.
This function is useful when another process connects to the same database file.") sync;
    bool sync() { return tctdbsync(self->_db); }

    %feature("docstring", "Optimize the file of a table database object.

This function is useful to reduce the size of the database file with data fragmentation by
successive updating. 

Arguments
bnum -- specifies the number of elements of the bucket array.  If it is not more than 0, the
default value is specified.  The default value is two times of the number of records.
apow -- specifies the size of record alignment by power of 2.  If it is negative, the current
setting is not changed.
fpow -- specifies the maximum number of elements of the free block pool by power of 2.  If it
is negative, the current setting is not changed.
opts -- specifies options by bitwise-or: `BDBTLARGE' specifies that the size of the database
can be larger than 2GB by using 64-bit bucket array, `BDBTDEFLATE' specifies that each record
is compressed with Deflate encoding, `BDBTBZIP' specifies that each record is compressed with
BZIP2 encoding, `BDBTTCBS' specifies that each record is compressed with TCBS encoding.  If it
is `UINT8_MAX', the current setting is not changed.

Returns
If successful, the return value is true, else, it is false.
") optimize;
    bool optimize(int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts) { 
        return tctdboptimize(self->_db, bnum, apow, fpow, opts);
    }

    %feature("docstring", "Remove all records of a table database object.

   If successful, the return value is true, else, it is false. ") vanish;
   bool vanish() { return tctdbvanish(self->_db); } 

   %feature("docstring", "Copy the database file of a table database object.

The database file is assured to be kept synchronized and not modified while the copying or
executing operation is in progress.  So, this function is useful to create a backup file of
the database file.

Arguments 
path -- specifies the path of the destination file.  If it begins with `@', the trailing
substring is executed as a command line.

Returns
If successful, the return value is true, else, it is false.  False is returned if the executed
command returns non-zero code.");   
    bool copy(const char *path) { 
        return tctdbcopy(self->_db, path);
    }

    %feature("docstring", "Begin the transaction of a table database object.

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
    bool tranbegin() {
        return tctdbtranbegin(self->_db);
    }

    %feature("docstring", "Commit the transaction of a table database object.

If successful, the return value is true, else, it is false.
Update in the transaction is fixed when it is committed successfully. 
") trancommit;
    bool trancommit() { 
        return tctdbtrancommit(self->_db);
    }

    %feature("docstring", "Abort the transaction of a table database object.

Update in the transaction is discarded when it is aborted.  The state of the database is
rollbacked to before transaction.

Returns
If successful, the return value is true, else, it is false.
") tranabort;
    bool tranabort() { 
        return tctdbtranabort(self->_db);
    }
    %feature("docstring", "Set a column index to a table database object.

Note that the setting indexes should be set after the database is opened.

Arguments
name -- specifies the name of a column.  If the name of an existing index is specified, the
   index is rebuilt.  An empty string means the primary key.
type -- specifies the index type: `TDBITLEXICAL' for lexical string, `TDBITDECIMAL' for decimal
   string.  If it is `TDBITOPT', the index is optimized.  If it is `TDBITVOID', the index is
   removed.  If `TDBITKEEP' is added by bitwise-or and the index exists, this function merely
   returns failure.
Returns
If successful, the return value is true, else, it is false.
") setindex;
    bool setindex(const std::string & name, int type) {
        return tctdbsetindex(self->_db, name.c_str(), type);
    }

    %feature("docstring", "Generate a unique ID number of a table database object.

Returns
The return value is the new unique ID number or -1 on failure.
") genuid;
    int64_t genuid() { return tctdbgenuid(self->_db); }

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
    static const long ITLEXICAL = 0;
    static const long ITDECIMAL = 1;
    static const long ITTOKEN = 2;
    static const long ITQGRAM = 3;
    static const long ITOPT = 9998;
    static const long ITVOID = 9999;
    static const long ITKEEP = 1 << 24;

};

class TDBQuery { 
    public:
    /* Hold onto the db reference, otherwise we'll segfault if the db goes away before we do. */
    %pythonappend TDBQuery(TDB *db) "self.__db = args[0]"
    TDBQuery(TDB *tdb) ;
    ~TDBQuery(); 
};


%extend TDBQuery {

    %feature("docstring", "Add a narrowing condition to a query object.

Arguments
qry -- specifies the query object.
name -- specifies the name of a column.  An empty string means the primary key.
op -- specifies an operation type: `TDBQCSTREQ' for string which is equal to the expression,
`TDBQCSTRINC' for string which is included in the expression, `TDBQCSTRBW' for string which
begins with the expression, `TDBQCSTREW' for string which ends with the expression,
`TDBQCSTRAND' for string which includes all tokens in the expression, `TDBQCSTROR' for string
which includes at least one token in the expression, `TDBQCSTROREQ' for string which is equal
to at least one token in the expression, `TDBQCSTRRX' for string which matches regular
expressions of the expression, `TDBQCNUMEQ' for number which is equal to the expression,
`TDBQCNUMGT' for number which is greater than the expression, `TDBQCNUMGE' for number which is
greater than or equal to the expression, `TDBQCNUMLT' for number which is less than the
expression, `TDBQCNUMLE' for number which is less than or equal to the expression, `TDBQCNUMBT'
for number which is between two tokens of the expression, `TDBQCNUMOREQ' for number which is
equal to at least one token in the expression.  All operations can be flagged by bitwise-or:
`TDBQCNEGATE' for negation, `TDBQCNOIDX' for using no index.
expr -- specifies an operand exression.") addcond;
    void addcond(const char *name, int op, const char *expr) { 
        tctdbqryaddcond(self->_q, name, op, expr);
   }
    %feature("docstring", "Set the order of a query object.

Arguments
qry -- specifies the query object.
name -- specifies the name of a column.  An empty string means the primary key.
type -- specifies the order type: `TDBQOSTRASC' for string ascending, `TDBQOSTRDESC' for
string descending, `TDBQONUMASC' for number ascending, `TDBQONUMDESC' for number descending.
") setorder;
    void setorder(const char* name, int type) {
        tctdbqrysetorder(self->_q, name, type);
    }

    %feature("docstring", "Set the limit number of records of the result of a query object.

Arguments
qry -- specifies the query object.
max -- specifies the maximum number of records of the result.  If it is negative, no limit is
specified.
skip -- specifies the number of skipped records of the result.  If it is not more than 0, no
record is skipped. 
") setlimit;
    void setlimit(int max, int skip) { 
        tctdbqrysetlimit(self->_q, max, skip);
    }

    %feature("docstring", "Execute the search of a query object.

Returns
The return value is a list object of the primary keys of the corresponding records.  This
function does never fail and return an empty list even if no record corresponds.
") search;
    %newobject search;
    TCLIST *search() {
        return tctdbqrysearch(self->_q);
    }

    %feature("docstring", "Remove each record corresponding to a query object.

Returns
If successful, the return value is true, else, it is false.") searchout;
   bool searchout() {
        return tctdbqrysearchout(self->_q);
    }

    %feature("docstring", "Get the hint of a query object.

Returns
The return value is the hint string.
") hint;
    const char *hint() { 
        return tctdbqryhint(self->_q);
    }

    static const long QCSTREQ = 0;
    static const long QCSTRINC = 1;
    static const long QCSTRBW = 2;
    static const long QCSTREW = 3;
    static const long QCSTRAND = 4;
    static const long QCSTROR = 5;
    static const long QCSTROREQ = 6;
    static const long QCSTRRX = 7;
    static const long QCNUMEQ = 8;
    static const long QCNUMGT = 9;
    static const long QCNUMGE = 10;
    static const long QCNUMLT = 11;
    static const long QCNUMLE = 12;
    static const long QCNUMBT = 13;
    static const long QCNUMOREQ = 14;
    static const long QCFTSPH = 15;
    static const long QCFTSAND = 16;
    static const long QCFTSOR = 17;
    static const long QCFTSEX = 18;
    static const long QCNEGATE = 1 << 24;
    static const long QCNOIDX = 1 << 25;
    static const long QOSTRASC = 0;
    static const long QOSTRDESC = 1;
    static const long QONUMASC = 2;
    static const long QONUMDESC = 3;
    static const long MSUNION = 0;
    static const long MSISECT = 1;
    static const long MSDIFF = 2;



};

%pythoncode %{ 

def metasearch(self, other_queries, setop): 
    """Search over multiple queries, including this one.

    Arguments
    other_queries -- TDBQuery, the other queries to search for.
    setop -- int, a set operation. One of MSUNION, MSISECT, MSDIFF 
    """
    def _metasearch():
        yield set(self.search())
        for q in other_queries:
            yield set(q.search())

    set_func = {
       self.MSUNION: set.union,
       self.MSISECT: set.intersection,
       self.MSDIFF: set.difference,
    }[setop]
    return reduce(set_func, _metasearch()) if other_queries else set()

TDBQuery.metasearch = metasearch

del metasearch

def items(self):
    self.iterinit()
    while True:
        key = self.iternext()
        if key is None:
            break
        print "key", repr(key)
        yield (key, self.get(key))

TDB.items = items

del items


def __setitem__(self, key, val): 
    self.put(key, val)

TDB.__setitem__ = __setitem__

del __setitem__

def __getitem__(self, key):
    val = self.get(key)
    if val is None:
        raise KeyError(key)
    return val

TDB.__getitem__ = __getitem__

del __getitem__

def keys(self): 
    """Iterate over all the keys"""
    self.iterinit()
    while True:
        key = self.iternext()
        if key is None:
            break
        yield key

TDB.__iter__ = keys
TDB.keys = keys
del keys

def values(self):
    """Iterator over all the values"""
    for k, v in self.items():
        yield v

TDB.values = values
del values

TDB.query = lambda self: TDBQuery(self)

%}


