%module(docstring="The B+ tree database API of Tokyo Cabinet", module="cabinet") bdb2
%include "typemaps.i"
%include "tcmaps2.i"

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


} TCBDB;


%rename(BDBCursor) BDBCUR;
typedef struct BDBCUR {
    %pythonappend BDBCUR(TCBDB *db) "self.__db = args[0]"
    %extend {
        BDBCUR(TCBDB *db) {
            return tcbdbcurnew(db); 
        };
        ~BDBCUR() { tcbdbcurdel(self); }

        bool first() { 
            return tcbdbcurfirst(self); 
        }
        bool last() {
            return tcbdbcurlast(self);
        }
        bool jump(const void **kbuf, int ksiz) {
            return tcbdbcurjump(self, kbuf, ksiz);
        }
        bool prev() { return tcbdbcurprev(self); }

        bool put(const void *vbuf, int vsiz, int cpmode) {
            return tcbdbcurput(self, vbuf, vsiz, cpmode);
        }

        void key(void **vbuf_out, int *vsiz_out) {
            *vbuf_out = tcbdbcurkey(self, vsiz_out);
        }
        void val(void **vbuf_out, int *vsiz_out) {
            *vbuf_out = tcbdbcurval(self, vsiz_out);
        }
        
        bool next() { 
            return tcbdbcurnext(self);
        }
        
        bool out() { 
            return tcbdbcurout(self);
        }

    }
} BDBCUR;

