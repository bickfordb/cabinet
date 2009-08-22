%module(docstring="The table database API of Tokyo Cabinet", module="tokyocabinet") tdb
%include "std_string.i"
%include "tcmaps.i"
%include "typemaps.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tctdb.h>
#include <string>
#include <map>

using namespace std;
typedef std::map<std::string, std::string> StringMap;
typedef std::pair<std::string, std::string> StringPair;

class TDBQuery;
class TDB;

class TDB {
    public:
    TDB() { 
        _db = tctdbnew();
    }
    ~TDB() {
        if (_db != NULL) tctdbdel(_db);
    }

    TCTDB *_db; 
};

%}

class TDB {
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


};

%pythoncode %{ 

%}
