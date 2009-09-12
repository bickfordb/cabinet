%module(docstring="The B+ tree database API of Tokyo Cabinet", module="cabinet") bdb
%include "typemaps.i"
%include "tcmaps.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tcbdb.h>
%}

%rename(BDB) TCBDB;
typedef struct TCBDB {
    %extend {
        TCBDB() {
            return tcbdbnew();
        };
        ~TCBDB() { 
            if (self) {
                tcbdbdel(self);
            }
        }

        bool put(const void *kbuf, int ksiz, const void *vbuf, int vsiz) {
            return tcbdbput(self, kbuf, ksiz, vbuf, vsiz);
        }

        bool __setitem__(const void *kbuf, int ksiz, const void *vbuf, int vsiz) {
            return tcbdbput(self, kbuf, ksiz, vbuf, vsiz);
        }


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
        TCLIST *fwmkeys(const void *kbuf, int ksiz, int max=-1) {
            return tcbdbfwmkeys(self, kbuf, ksiz, max);
        }

        bool tune(long lmemb, long nmemb,
                     long long bnum, long apow, long fpow, long opts) {
            return tcbdbtune(self, lmemb, nmemb, bnum, apow, fpow, opts); 
        }

        bool setcache(long lcnum, long ncnum) {
            return tcbdbsetcache(self, lcnum, ncnum);
        }

        bool setxmsiz(long long xmsiz) {
            return tcbdbsetxmsiz(self, xmsiz);
        }

        bool open(const char* path, long omode) {
            return tcbdbopen(self, path, omode);
        }
        bool close() {
            return tcbdbclose(self);
        }

        bool putkeep(const void *kbuf, int ksiz, const void *vbuf, int vsiz) {
            return tcbdbputkeep(self, kbuf, ksiz, vbuf, vsiz);
        }

        bool out(const void *kbuf, int ksiz) {
            return tcbdbout(self, kbuf, ksiz);
        }

        void get(const void *kbuf, int ksiz, void **vbuf_out, int *vsiz_out) {
            *vbuf_out = tcbdbget(self, kbuf, ksiz, vsiz_out);
        }

        long vsiz(const void *kbuf, int ksiz) { 
            return tcbdbvsiz(self, kbuf, ksiz);
        };

        long addint(const void *kbuf, int ksiz, long num) {
            return tcbdbaddint(self, kbuf, ksiz, num);
        }

        double adddouble(const void *kbuf, int ksiz, double num) {
            return tcbdbadddouble(self, kbuf, ksiz, num);
        }

        bool sync() {
            return tcbdbsync(self);
        }

        bool optimize(TCBDB *bdb, int32_t lmemb, int32_t nmemb,
                   int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts) {
            return tcbdboptimize(self, lmemb, nmemb, bnum, apow, fpow, opts);
        }

        bool vanish() {
            return tcbdbvanish(self);
        }
        bool copy(const char* path) {
            return tcbdbcopy(self, path);
        }
        bool tranbegin() { 
            return tcbdbtranbegin(self);
        }

        bool trancommit() {
            return tcbdbtrancommit(self);
        }
        bool tranabort() { 
            return tcbdbtranabort(self);
        }

        const char *path() {
            return tcbdbpath(self);
        }

        long long rnum() { 
            return tcbdbrnum(self); 
        }

        long long __len__() { 
            return tcbdbrnum(self);
        }

        long long fsiz() {
            return tcbdbfsiz(self);
        }

        bool putcat(const void *kbuf, int ksiz, const void *vbuf, int vsiz) {
            return tcbdbputcat(self, kbuf, ksiz, vbuf, vsiz);
        }

        const char * errmsg(long ecode=-1) {
            if (ecode == -1) { 
                ecode = tcbdbecode(self);
            }
            return tcbdberrmsg(ecode);
        }

        long ecode() { 
            return tcbdbecode(self);
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

        static const long ESUCCESS = 0;
        static const long ETHREAD = 1;
        static const long EINVALID = 2;
        static const long ENOFILE = 3;
        static const long ENOPERM = 4;
        static const long EMETA = 5;
        static const long ERHEAD = 6;
        static const long EOPEN = 7;
        static const long ECLOSE = 8;
        static const long ETRUNC = 9;
        static const long ESYNC = 10;
        static const long ESTAT = 11;
        static const long ESEEK = 12;
        static const long EREAD = 13;
        static const long EWRITE = 14;
        static const long EMMAP = 15;
        static const long ELOCK = 16;
        static const long EUNLINK = 17;
        static const long ERENAME = 18;
        static const long EMKDIR = 19;
        static const long ERMDIR = 20;
        static const long EKEEP = 21;
        static const long ENOREC = 22;
        static const long EMISC = 9999;


    }

    %pythoncode {
    
    def cursor(self):
        """Get a BDBCursor"""
        return BDBCursor(self)

    def __iter__(self):
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

    iterkeys = keys

    def values(self): 
        """Iterate over all the values in the database"""
        for k, v in self:
            yield v

    itervalues = values

    def __getitem__(self, key):
        val = self.get(key)
        if val is None:
            raise KeyError(key)
        return val
    }

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

    %feature("docstring", "Set the size of the extra mapped memory of a B+ tree database object.

Note that the mapping parameters should be set before the database is opened.

Arguments 
xmsiz -- int, specifies the size of the extra mapped memory.  If it is not more than 0, the extra
mapped memory is disabled.  It is disabled by default.

Returns
If successful, the return value is true, else, it is false.
") setxmsiz;

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

    %feature("docstring", "Close the database") close;
    
    %feature("docstring", "Store a new record into a B+ tree database object.

Arguments:
key -- the key
value -- the value

Returns:
boolean") put;

    %feature("docstring", "Store a new record into a B+ tree database object.

If a record with the same key exists in the database, this function has no effect. 

Arguments
key -- str, the key
value -- str, the value

Returns
If successful, the return value is true, else, it is false.
") putkeep;

    %feature("docstring", "Concatenate a value at the end of the existing record in a B+ tree database object.

If there is no corresponding record, a new record is created. 

Arguments
key -- str, the key
value -- str, the value

Returns
If successful, the return value is true, else, it is false.
") putcat;
    
    %feature("docstring", "Remove a record of a B+ tree database object.

If the key of duplicated records is specified, the first one is selected.

Arguments
key -- str, the key

Returns
If successful, the return value is true, else, it is false.
") out;

    %feature("docstring", "Retrieve a record in a B+ tree database object.
 
If the key of duplicated records is specified, the first one is selected.  

Arguments
key -- str, the key 

Returns
The value or None
") get;
    
    %feature("docstring", "Get the size of the value of a record in a B+ tree
%database object.

If the key of duplicated records is specified, the first one is selected. 

Returns
key -- str, the key

Returns
If successful, the return value is the size of the value of the corresponding record, else,
it is -1.
") vsiz;

    %feature("docstring", "Add an integer to a record in a B+ tree database object.

If the corresponding record exists, the value is treated as an integer and is added to.  If no
record corresponds, a new record of the additional value is stored. 

Arguments
key -- str, specifies the pointer to the region of the key.
num -- int, specifies the additional value.

Returns
If successful, the return value is the summation value, else, it is `INT_MIN'.

") addint;

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

    %feature("docstring", "Synchronize updated contents of a B+ tree database object with the file and the device.

This function is useful when another process connects to the same database file.

Returns
If successful, the return value is true, else, it is false.
") sync;

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

    %feature("docstring", "Remove all records of a B+ tree database object.
   `bdb' specifies the B+ tree database object connected as a writer.
   If successful, the return value is true, else, it is false. ") vanish;

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

    %feature("docstring", "Commit the transaction of a B+ tree database object.

Update in the transaction is fixed when it is committed successfully.

Returns
If successful, the return value is true, else, it is false.
") trancommit;

    %feature("docstring", "Abort the transaction of a B+ tree database object.

Update in the transaction is discarded when it is aborted.  The state of the
database is rollbacked to before transaction.

Returns
If successful, the return value is true, else, it is false.
") tranabort;

    %feature("docstring", "Get the file path of a B+ tree database object.

Returns
The return value is the path of the database file or `NULL' if the object does
not connect to any database file.") path;

    %feature("docstring", "Get the number of records of a B+ tree database object.

Returns
The return value is the number of records or 0 if the object does not connect
to any database file.") rnum;

    %feature("docstring", "Get the size of the database file of a B+ tree database object.

Returns
The return value is the size of the database file or 0 if the object does not connect to any
database file.") fsiz;


} TCBDB;


%rename(BDBCursor) BDBCUR;
typedef struct BDBCUR {
    %pythonappend BDBCUR(TCBDB *db) "self.__db = args[0]"
    %extend {
        BDBCUR(TCBDB *db) {
            return tcbdbcurnew(db); 
        };
        ~BDBCUR() { tcbdbcurdel(self); }

        %feature("docstring", "Move a cursor object to the first record.
If successful, the return value is true, else, it is false.  False is returned if there is
no record in the database.") first;
        bool first() { 
            return tcbdbcurfirst(self); 
        }
  
        %feature("docstring",  "Move a cursor object to the last record.
If successful, the return value is true, else, it is false.  False is returned if there is
no record in the database.
") last;
        bool last() {
            return tcbdbcurlast(self);
        }


        %feature("docstring", "Move a cursor object to the front of records corresponding a key.
The cursor is set to the first record corresponding the key or the next substitute if
completely matching record does not exist. 
Arguments:
key -- string, the key to move to
Returns:
If successful, the return value is true, else, it is false.  False is returned if there is
no record corresponding the condition.
") jump;
        bool jump(const void **kbuf, int ksiz) {
            return tcbdbcurjump(self, kbuf, ksiz);
        }
        %feature("docstring", "Move a cursor object to the previous record.

Returns:
If successful, the return value is true, else, it is false.  False is returned if there is
no previous record. 
") prev;

        bool prev() { return tcbdbcurprev(self); }

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
        bool put(const void *vbuf, int vsiz, int cpmode) {
            return tcbdbcurput(self, vbuf, vsiz, cpmode);
        }


        %feature("docstring", "Get the key of the record where the cursor object is.

Returns:
string or None
") key;
        void key(void **vbuf_out, int *vsiz_out) {
            *vbuf_out = tcbdbcurkey(self, vsiz_out);
        }


    %feature("docstring", "Get the value of the record where the cursor object is.

Returns:
string or None
") val;
        void val(void **vbuf_out, int *vsiz_out) {
            *vbuf_out = tcbdbcurval(self, vsiz_out);
        }
        
        %feature("docstring", "Move a cursor object to the next record.

Returns:
If successful, the return value is true, else, it is false.  False is returned if there is
no next record.
") next;
        bool next() { 
            return tcbdbcurnext(self);
        }

        %feature("docstring", "Remove the record where a cursor object is.

After deletion, the cursor is moved to the next record if possible. 

Returns:
If successful, the return value is true, else, it is false.  False is returned when the cursor
is at invalid position.
") out; 
        bool out() { 
            return tcbdbcurout(self);
        }

    }
} BDBCUR;

