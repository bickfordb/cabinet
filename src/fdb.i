%module(docstring="The fixed length database API of Tokyo Cabinet", module="cabinet") fdb
%include "typemaps.i"
%include "std_string.i"
%include "tcmaps.i"
%include "ecode.i"
%{
#define SWIG_FILE_WITH_INIT
#include <tcfdb.h>
#include <string>

class FDB : ECODE {
    public:
    FDB() { 
        this->_db = tcfdbnew();
    }
    ~FDB() {
        if (this->_db) tcfdbdel(_db);
    }

    const char * errmsg(long ecode=-1) {
        if (ecode == -1) 
            ecode = tcfdbecode(_db);
        return tcfdberrmsg(ecode);
    }

    long ecode() {
        return tcfdbecode(_db);
    }

    TCFDB *_db;
};

%}

class FDB : ECODE {
    public:
    FDB();
    ~FDB();
};

%extend FDB { 
    bool open(const std::string & name, int mode) { 
       return tcfdbopen(self->_db, name.c_str(), mode); 
    }
    bool close() { 
        return tcfdbclose(self->_db);
    }


    bool tune(int width, long long limsiz) { 
        return tcfdbtune(self->_db, width, limsiz);
    }
    bool optimize(int width, long long limsiz) { 
        return tcfdboptimize(self->_db, width, limsiz);
    }

    bool put(long long key, const std::string & val) { 
        return tcfdbput(self->_db, key, val.c_str(), val.length()); 
    }

    bool putkeep(long long key, const std::string & val) { 
        return tcfdbputkeep(self->_db, key, val.c_str(), val.length()); 
    }
    bool putcat(long long key, const std::string & val) { 
        return tcfdbputcat(self->_db, key, val.c_str(), val.length()); 
    }
    bool out(long long key) { 
        return tcfdbout(self->_db, key); 
    } 
    

    %newobject get;
    std::string *get(long long key) { 
        int sz = 0 ;
        void *buf = tcfdbget(self->_db, key, &sz); 
        std::string *result = buf != NULL ? new std::string((const char*)buf, sz) : NULL;
        free(buf);
        return result;
    } 

    int vsiz(long long key) {
        return tcfdbvsiz(self->_db, key);
    }

    bool iterinit() { 
        return tcfdbiterinit(self->_db);
    }

    long long iternext() {
        return tcfdbiternext(self->_db);
    }

    int addint(long long id, int num) { 
        return tcfdbaddint(self->_db, id, num);
    }

    double adddouble(long long id, double num) { 
        return tcfdbadddouble(self->_db, id, num);
    }
    bool sync() {
        return tcfdbsync(self->_db);
    }
    
    bool vanish() {
        return tcfdbvanish(self->_db);
    }
    bool copy(const std::string & path) {
        return tcfdbcopy(self->_db, path.c_str());
    }

    unsigned long long rnum() {
        return tcfdbrnum(self->_db);
    }

    bool tranbegin() { 
        return tcfdbtranbegin(self->_db);
    } 

    bool tranabort() {
        return tcfdbtranabort(self->_db);
    }

    bool trancommit() { 
        return tcfdbtrancommit(self->_db);
    }

    uint64_t fsiz() { 
        return tcfdbfsiz(self->_db);
    }
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

FDB.keys = keys
del keys

def values(self): 
    """Iterate over all the values in the database"""
    for k, v in self:
        yield v

FDB.values = values
del values

def __getitem__(self, key):
    val = self.get(key)
    if val is None:
        raise KeyError(key)
    return val

FDB.__getitem__ = __getitem__
del __getitem__

FDB.__setitem__ = FDB.put

def items(self): 
    self.iterinit()
    while True:
        i = self.iternext()
        if i == 0:
            break
        yield i, self.get(i)

FDB.items = items
FDB.__iter__ = items
FDB.__len__ = FDB.rnum

%}


