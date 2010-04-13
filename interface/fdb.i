%module(docstring="The fixed length database API of Tokyo Cabinet", module="cabinet") fdb
%include "typemaps.i"
%include "tcmaps.i"
%{
#define SWIG_FILE_WITH_INIT
#include <tcfdb.h>
%}

%rename (FDB) TCFDB;
typedef struct { 
%extend { 
    
    TCFDB() { 
        return tcfdbnew();
    }
    ~TCFDB() {
        if (self) tcfdbdel(self);
    }

    const char * errmsg(long ecode=-1) {
        if (ecode == -1) 
            ecode = tcfdbecode(self);
        return tcfdberrmsg(ecode);
    }

    long ecode() {
        return tcfdbecode(self);
    }

    bool open(const char *name, int mode) { 
       return tcfdbopen(self, name, mode); 
    }
    bool close() { 
        return tcfdbclose(self);
    }


    bool tune(int width, long long limsiz) { 
        return tcfdbtune(self, width, limsiz);
    }
    bool optimize(int width, long long limsiz) { 
        return tcfdboptimize(self, width, limsiz);
    }

    bool put(long long key, const void *vbuf, int vsiz) { 
        return tcfdbput(self, key, vbuf, vsiz); 
    }

    bool putkeep(long long key, const void *vbuf, int vsiz) { 
        return tcfdbputkeep(self, key, vbuf, vsiz); 
    }
    bool putcat(long long key, const void *vbuf, int vsiz) { 
        return tcfdbputcat(self, key, vbuf, vsiz); 
    }
    bool out(long long key) { 
        return tcfdbout(self, key); 
    } 
    
    void get(long long key, void **vbuf_out, int *vsiz_out) { 
        *vbuf_out = tcfdbget(self, key, vsiz_out);
    } 

    int vsiz(long long key) {
        return tcfdbvsiz(self, key);
    }

    bool iterinit() { 
        return tcfdbiterinit(self);
    }

    long long iternext() {
        return tcfdbiternext(self);
    }

    int addint(long long id, int num) { 
        return tcfdbaddint(self, id, num);
    }

    double adddouble(long long id, double num) { 
        return tcfdbadddouble(self, id, num);
    }
    bool sync() {
        return tcfdbsync(self);
    }
    
    bool vanish() {
        return tcfdbvanish(self);
    }
    bool copy(const char *path) {
        return tcfdbcopy(self, path);
    }

    unsigned long long rnum() {
        return tcfdbrnum(self);
    }

    bool tranbegin() { 
        return tcfdbtranbegin(self);
    } 

    bool tranabort() {
        return tcfdbtranabort(self);
    }

    bool trancommit() { 
        return tcfdbtrancommit(self);
    }

    uint64_t fsiz() { 
        return tcfdbfsiz(self);
    }
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

    __setitem__ = put

    def items(self): 
        self.iterinit()
        while True:
            i = self.iternext()
            if i == 0:
                break
            yield i, self.get(i)

    items = items
    __iter__ = keys
    __len__ = rnum

%}
}
} TCFDB;


