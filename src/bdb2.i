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
        void __getitem__(const void *kbuf, int ksiz, void **vbuf_out, int *vsiz_out) {
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

    }
     

} TCBDB;

