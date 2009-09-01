%module(docstring="The hash database API of Tokyo Cabinet", module="cabinet") hdb
%include "typemaps.i"
%include "std_string.i"
%include "tcmaps.i"
%include "ecode.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tchdb.h>
#include <string>

class HDB : ECODE {
    public:
    HDB() { 
        this->_db = tchdbnew();
    }
    ~HDB() {
        if (this->_db) tchdbdel(_db);
    }
    TCHDB *_db;

    const char * errmsg(long ecode=-1) {
        if (ecode == -1)
            ecode = tchdbecode(_db);
        return tchdberrmsg(ecode);
    }
    long ecode() { 
        return tchdbecode(_db);
    }
};

%}

class HDB : ECODE {
    public:
    HDB();
    ~HDB();
};

%extend HDB { 
    bool open(const std::string & name, int mode) { 
       return tchdbopen(self->_db, name.c_str(), mode); 
    }
    bool close() { 
        return tchdbclose(self->_db);
    }

    bool tune(long long bnum, int8_t apow, int8_t fpow, uint8_t opts) { 
        return tchdbtune(self->_db, bnum, apow, fpow, opts);
    }
    bool setcache(long rcnum) { 
        return tchdbsetcache(self->_db, rcnum);
    }

    bool setxmsiz(long long xmsiz) { 
        return tchdbsetxmsiz(self->_db, xmsiz);
    }

    bool setdfunit(long dfunit) { 
        return tchdbsetdfunit(self->_db, dfunit);
    }

    bool putasync(const std::string & key, const std::string & val) { 
        return tchdbputasync(self->_db, key.c_str(), key.length(), val.c_str(), val.length());
    }

    bool put(const std::string & key, const std::string & val) { 
        return tchdbput(self->_db, key.c_str(), key.length(), val.c_str(), val.length()); 
    }
    bool putkeep(const std::string & key, const std::string & val) { 
        return tchdbputkeep(self->_db, key.c_str(), key.length(), val.c_str(), val.length()); 
    }
    bool putcat(const std::string & key, const std::string & val) { 
        return tchdbputcat(self->_db, key.c_str(), key.length(), val.c_str(), val.length()); 
    }
    bool out(const std::string & key) { 
        return tchdbout(self->_db, key.c_str(), key.length()); 
    } 
    
    %newobject get;
    std::string *get(const std::string & key) { 
        int sz = 0 ;
        void *buf = tchdbget(self->_db, key.c_str(), key.length(), &sz); 
        return buf != NULL ? new std::string((const char*)buf, sz) : NULL;
    } 

    long vsiz(const std::string & key) {
        return tchdbvsiz(self->_db, key.c_str(), key.length());
    }

    bool iterinit() { 
        return tchdbiterinit(self->_db);
    }

    %newobject iternext;
    std::string *iternext() {
        int sz = 0;
        void *buf = tchdbiternext(self->_db, &sz);
        std::string *result = NULL;
        if (buf != NULL) {
            result = new std::string((const char*)buf, sz);
            free(buf);
        }
        return result;
    }

    %newobject fwmkeys;
    TCLIST *fwmkeys(const std::string & prefix, int max=-1) {
        return tchdbfwmkeys(self->_db, prefix.c_str(), prefix.length(), max);
    }
    
    int addint(const std::string & key, int num) { 
        return tchdbaddint(self->_db, key.c_str(), key.length(), num);
    }

    double adddouble(const std::string & key, double num) { 
        return tchdbadddouble(self->_db, key.c_str(), key.length(), num);
    }
    bool sync() {
        return tchdbsync(self->_db);
    }
    
    bool vanish() {
        return tchdbvanish(self->_db);
    }
    bool copy(const std::string & path) {
        return tchdbcopy(self->_db, path.c_str());
    }

    unsigned long long rnum() {
        return tchdbrnum(self->_db);
    }

    bool tranbegin() { 
        return tchdbtranbegin(self->_db);
    } 

    bool tranabort() {
        return tchdbtranabort(self->_db);
    }

    bool trancommit() { 
        return tchdbtrancommit(self->_db);
    }

    bool optimize(long long bnum, int8_t apow, int8_t fpow, uint8_t opts) {
        return tchdboptimize(self->_db, bnum, apow, fpow, opts);
    }

    uint64_t fsiz() { 
        return tchdbfsiz(self->_db);
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

def keys(self):
    """Iterate over all the keys in the database"""
    for k, v in self:
        yield k

HDB.keys = keys
del keys

def values(self): 
    """Iterate over all the values in the database"""
    for k, v in self:
        yield v

HDB.values = values
del values

def __getitem__(self, key):
    val = self.get(key)
    if val is None:
        raise KeyError(key)
    return val

HDB.__getitem__ = __getitem__
del __getitem__

HDB.__setitem__ = HDB.put

def items(self): 
    self.iterinit()
    while True:
        i = self.iternext()
        if i is None:
            break
        yield i, self.get(i)

HDB.items = items
HDB.__iter__ = items
HDB.__len__ = HDB.rnum

%}


