%module(docstring="The abstract database API of Tokyo Cabinet", module="cabinet") adb
%include "typemaps.i"
%include "tcmaps.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tcadb.h>

%}

%rename (ADB) TCADB;

typedef struct { 
%extend {
    TCADB() { 
        return tcadbnew();
    }
    ~ADB() {
        if (self) tcadbdel(self);
    }
    bool open(const char *name) { 
       return tcadbopen(self, name); 
    }
    bool close() { 
        return tcadbclose(self);
    }
    bool put(const void *kbuf, int ksiz, const void *vbuf, int vsiz) { 
        return tcadbput(self, kbuf, ksiz, vbuf, vsiz); 
    }
    bool putkeep(const void *kbuf, int ksiz, const void *vbuf, int vsiz) { 
        return tcadbputkeep(self, kbuf, ksiz, vbuf, vsiz); 
    }
    bool putcat(const void *kbuf, int ksiz, const void *vbuf, int vsiz) { 
        return tcadbputcat(self, kbuf, ksiz, vbuf, vsiz); 
    }
    bool out(const void *kbuf, int ksiz) { 
        return tcadbout(self, kbuf, ksiz); 
    } 
    
    void get(const void *kbuf, int ksiz, void **vbuf_out, int *vsiz_out) { 
        *vbuf_out = tcadbget(self, kbuf, ksiz, vsiz_out); 
    } 

    long vsiz(const void *kbuf, int ksiz) {
        return tcadbvsiz(self, kbuf, ksiz);
    }

    bool iterinit() { 
        return tcadbiterinit(self);
    }

    void iternext(void **kbuf_out, int *ksiz_out) {
        *kbuf_out = tcadbiternext(self, ksiz_out);
    }

    %newobject fwmkeys;
    TCLIST *fwmkeys(const void *kbuf, int ksiz, int max=-1) {
        return tcadbfwmkeys(self, kbuf, ksiz, max);
    }
    
    int addint(const void *kbuf, int ksiz, int num) { 
        return tcadbaddint(self, kbuf, ksiz, num);
    }

    double adddouble(const void *kbuf, int ksiz, double num) { 
        return tcadbadddouble(self, kbuf, ksiz, num);
    }
    bool sync() {
        return tcadbsync(self);
    }
    
    bool vanish() {
        return tcadbvanish(self);
    }
    bool copy(const char *path) {
        return tcadbcopy(self, path);
    }

    unsigned long long rnum() {
        return tcadbrnum(self);
    }

    bool tranbegin() { 
        return tcadbtranbegin(self);
    } 

    bool tranabort() {
        return tcadbtranabort(self);
    }

    bool trancommit() { 
        return tcadbtrancommit(self);
    }

    bool optimize(const char * params) { 
        return tcadboptimize(self, params);
    }

    uint64_t size() { 
        return tcadbsize(self);
    }

    %newobject misc;
    TCLIST *misc(const char *name, const TCLIST *args) {
        return tcadbmisc(self, name, args);
    }
    %pythoncode %{ 

    def keys(self):
        """Iterate over all the keys in the database"""
        self.iterinit()
        key = self.iternext()
        while key is not None:
            yield key
            key = self.iternext()

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
            if i is None:
                break
            yield i, self.get(i)

    items = items
    __iter__ = keys
    __len__ = rnum
    %}
}
} TCADB;



