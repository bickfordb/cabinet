%module(docstring="The abstract database API of Tokyo Cabinet", module="tokyocabinet") adb
%include "typemaps.i"
%include "std_string.i"
%include "tcmaps.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tcadb.h>
#include <string>

class ADB {
    public:
    ADB() { 
        this->_db = tcadbnew();
    }
    ~ADB() {
        if (this->_db) tcadbdel(_db);
    }
    TCADB *_db;
};

%}

class ADB {
    public:
    ADB();
    ~ADB();
};

%extend ADB { 
    bool open(const std::string & name) { 
       return tcadbopen(self->_db, name.c_str()); 
    }
    bool close() { 
        return tcadbclose(self->_db);
    }
    bool put(const std::string & key, const std::string & val) { 
        return tcadbput(self->_db, key.c_str(), key.length(), val.c_str(), val.length()); 
    }
    bool putkeep(const std::string & key, const std::string & val) { 
        return tcadbputkeep(self->_db, key.c_str(), key.length(), val.c_str(), val.length()); 
    }
    bool putcat(const std::string & key, const std::string & val) { 
        return tcadbputcat(self->_db, key.c_str(), key.length(), val.c_str(), val.length()); 
    }
    bool out(const std::string & key) { 
        return tcadbout(self->_db, key.c_str(), key.length()); 
    } 
    
    %newobject get;
    std::string *get(const std::string & key) { 
        int sz = 0 ;
        void *buf = tcadbget(self->_db, key.c_str(), key.length(), &sz); 
        return buf != NULL ? new std::string((const char*)buf, sz) : NULL;
    } 

    long vsiz(const std::string & key) {
        return tcadbvsiz(self->_db, key.c_str(), key.length());
    }

    bool iterinit() { 
        return tcadbiterinit(self->_db);
    }

    %newobject iternext;
    std::string *iternext() {
        int sz = 0;
        void *buf = tcadbiternext(self->_db, &sz);
        std::string *result = NULL;
        if (buf != NULL) {
            result = new std::string((const char*)buf, sz);
            free(buf);
        }
        return result;
    }

    %newobject fwmkeys;
    TCLIST *fwmkeys(const std::string & prefix, int max=-1) {
        return tcadbfwmkeys(self->_db, prefix.c_str(), prefix.length(), max);
    }
    
    int addint(const std::string & key, int num) { 
        return tcadbaddint(self->_db, key.c_str(), key.length(), num);
    }

    double adddouble(const std::string & key, double num) { 
        return tcadbadddouble(self->_db, key.c_str(), key.length(), num);
    }
    bool sync() {
        return tcadbsync(self->_db);
    }
    
    bool vanish() {
        return tcadbvanish(self->_db);
    }
    bool copy(const std::string & path) {
        return tcadbcopy(self->_db, path.c_str());
    }

    unsigned long long rnum() {
        return tcadbrnum(self->_db);
    }

    bool tranbegin() { 
        return tcadbtranbegin(self->_db);
    } 

    bool tranabort() {
        return tcadbtranabort(self->_db);
    }

    bool trancommit() { 
        return tcadbtrancommit(self->_db);
    }

    bool optimize(const std::string & params) { 
        return tcadboptimize(self->_db, params.c_str());
    }

    uint64_t size() { 
        return tcadbsize(self->_db);
    }

    %newobject misc;
    TCLIST *misc(const char *name, const TCLIST *args) {
        return tcadbmisc(self->_db, name, args);
    }
};

%pythoncode %{ 

def keys(self):
    """Iterate over all the keys in the database"""
    for k, v in self:
        yield k

ADB.keys = keys
del keys

def values(self): 
    """Iterate over all the values in the database"""
    for k, v in self:
        yield v

ADB.values = values
del values

def __getitem__(self, key):
    val = self.get(key)
    if val is None:
        raise KeyError(key)
    return val

ADB.__getitem__ = __getitem__
del __getitem__

ADB.__setitem__ = ADB.put

def items(self): 
    self.iterinit()
    while True:
        i = self.iternext()
        if i is None:
            break
        yield i, self.get(i)

ADB.items = items
ADB.__iter__ = items
ADB.__len__ = ADB.rnum

%}

