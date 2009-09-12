%module(docstring="The hash database API of Tokyo Cabinet", module="cabinet") hdb
%include "typemaps.i"
%include "tcmaps.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tchdb.h>
%}

%rename (HDB) TCHDB;
typedef struct {
    %extend { 

    TCHDB() { 
        return tchdbnew();
    }
    ~TCHDB() {
        if (self) tchdbdel(self);
    }

    const char * errmsg(long ecode=-1) {
        if (ecode == -1)
            ecode = tchdbecode(_db);
        return tchdberrmsg(ecode);
    }
    long ecode() { 
        return tchdbecode(_db);
    }

    bool open(const char *name, int mode) { 
       return tchdbopen(self, name, mode); 
    }
    bool close() { 
        return tchdbclose(self);
    }

    bool tune(long long bnum, int8_t apow, int8_t fpow, uint8_t opts) { 
        return tchdbtune(self, bnum, apow, fpow, opts);
    }
    bool setcache(long rcnum) { 
        return tchdbsetcache(self, rcnum);
    }

    bool setxmsiz(long long xmsiz) { 
        return tchdbsetxmsiz(self, xmsiz);
    }

    bool setdfunit(long dfunit) { 
        return tchdbsetdfunit(self, dfunit);
    }

    bool putasync(const void *kbuf, int ksiz, const void *vbuf, int vsiz) { 
        return tchdbputasync(self, kbuf, ksiz, vbuf, vsiz);
    }

    bool put(const void *kbuf, int ksiz, const void *vbuf, int vsiz) { 
        return tchdbput(self, kbuf, ksiz, vbuf, vsiz); 
    }
    bool putkeep(const void *kbuf, int ksiz, const void *vbuf, int vsiz) { 
        return tchdbputkeep(self, kbuf, ksiz, vbuf, vsiz); 
    }
    bool putcat(const void *kbuf, int ksiz, const void *vbuf, int vsiz) { 
        return tchdbputcat(self, kbuf, ksiz, vbuf, vsiz); 
    }
    bool out(const void *kbuf, int ksiz) { 
        return tchdbout(self, kbuf, ksiz); 
    } 
    
    void get(const void *kbuf, int ksiz, void **vbuf_out, int *vsiz_out) { 
        *vbuf_out = tchdbget(self, kbuf, ksiz, vsiz_out); 
    } 

    long vsiz(const void *kbuf, int ksiz) {
        return tchdbvsiz(self, kbuf, ksiz);
    }

    bool iterinit() { 
        return tchdbiterinit(self);
    }

    void iternext(void **kbuf_out, int *ksiz_out) {
        kbuf_out = tchdbiternext(self, ksiz_out);
    }

    %newobject fwmkeys;
    TCLIST *fwmkeys(const void *kbuf, int ksiz, int max=-1) {
        return tchdbfwmkeys(self, kbuf, ksiz, max);
    }
    
    int addint(const void *kbuf, int ksiz, int num) { 
        return tchdbaddint(self, kbuf, ksiz, num);
    }

    double adddouble(const void *kbuf, int ksiz, double num) { 
        return tchdbadddouble(self, kbuf, ksiz, num);
    }
    bool sync() {
        return tchdbsync(self);
    }
    
    bool vanish() {
        return tchdbvanish(self);
    }
    bool copy(const char *path) {
        return tchdbcopy(self, path);
    }

    unsigned long long rnum() {
        return tchdbrnum(self);
    }

    bool tranbegin() { 
        return tchdbtranbegin(self);
    } 

    bool tranabort() {
        return tchdbtranabort(self);
    }

    bool trancommit() { 
        return tchdbtrancommit(self);
    }

    bool optimize(long long bnum, int8_t apow, int8_t fpow, uint8_t opts) {
        return tchdboptimize(self, bnum, apow, fpow, opts);
    }

    uint64_t fsiz() { 
        return tchdbfsiz(self);
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
    %pythoncode %{ 

    def keys(self):
        """Iterate over all the keys in the database"""
        for k, v in self:
            yield k

    def values(self): 
        """Iterate over all the values in the database"""
        for k, v in self:
            yield v

    def __getitem__(self, key):
        val = self.get(key)
        if val is None:
            raise KeyError(key)
        return val

    def items(self): 
        self.iterinit()
        while True:
            i = self.iternext()
            if i is None:
                break
            yield i, self.get(i)

    iteritems = items

    __iter__ = keys

    __len__ = rnum
    %}    
}
} TCHDB;

