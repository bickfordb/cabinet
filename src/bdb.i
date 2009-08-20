%module bdb

%{
#define SWIG_FILE_WITH_INIT
#include <tcbdb.h>
class BDB {
    public:
    BDB() { 
        this->_db = tcbdbnew();
    }
    ~BDB() {
        if (this->_db) tcbdbdel(_db);
    }
    TCBDB *_db; 
};

%}

class BDB {
    TCBDB *_db;
};

%extend BDB { 
    
    %feature("autodoc") tune;
    bool tune(long lmemb, long nmemb,
                     long long bnum, long apow, long fpow, long opts) {
        return tcbdbtune(self->_db, lmemb, nmemb, bnum, apow, fpow, opts); 
    }
    %feature("autodoc") setcache;
    bool setcache(long lcnum, long ncnum) {
        return tcbdbsetcache(self->_db, lcnum, ncnum);
    }
    %feature("autodoc") setmxsiz;
    bool setxmsiz(long long xmsiz) {
        return tcbdbsetxmsiz(self->_db, xmsiz);
    }

    %feature("autodoc") open;
    bool open(const char* path, long omode) {
        return tcbdbopen(self->_db, path, omode);
    }

    %feature("autodoc") close;
    bool close() {
        return tcbdbclose(self->_db);
    }
    
    %apply (char *STRING, int LENGTH) { (const void *key, int key_size) };
    %apply (char *STRING, int LENGTH) { (const void *value, int value_size) };
    

    %feature("docstring", "Store a new record into a B+ tree database object.

Arguments:
key -- the key
value -- the value

Returns:
boolean") put;
    bool put(const void* key, int key_size, const void* value, int value_size) {
        return tcbdbput(self->_db, key, key_size, value, value_size);
    };

    %feature("autodoc", "Concatenate a value at the end of the existing record in a B+ tree database object.") putkeep;
    bool putkeep(const void *key, int key_size , const void *value, int value_size) {
        return tcbdbputkeep(self->_db, key, key_size, value, value_size);
    }

    %feature("docstring", "Concatenate a value at the end of the existing record in a B+ tree database object.") putcat;
    bool putcat(const void* key, int key_size, const void* value, int value_size) {
        return tcbdbputcat(self->_db, key, key_size, value, value_size);
    }
    
    // bool putasync(const void* key, int key_size, const void *value, int value_size) ;

    bool out(const void* key, int key_size) {
        return tcbdbout(self->_db, key, key_size);
    }

    PyObject* get(const void* key, int key_size) {
        int value_size = 0;
        void *value = tcbdbget(self->_db, key, key_size, &value_size);    
        if (value != NULL) {
            PyObject *result = PyString_FromStringAndSize((const char*)value, value_size);
            free(value);
            return result;
        } else { 
            return Py_None;
        } 
    }
    long vsiz(const void* key, int key_size) { 
        return tcbdbvsiz(self->_db, key, key_size);
    };

    // bool iterinit() ;
    // const char* iternext();
    //List fwmkeys(const char* prefix, long max);
    long addint(const void* key, int key_size, long num) {
        return tcbdbaddint(self->_db, key, key_size, num);
    }
    double adddouble(const void* key, int key_size, double num) {
        return tcbdbadddouble(self->_db, key, key_size, num);
    }
    bool sync() {
        return tcbdbsync(self->_db);
    }

    bool optimize(TCBDB *bdb, int32_t lmemb, int32_t nmemb,
                   int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts) {
        return tcbdboptimize(self->_db, lmemb, nmemb, bnum, apow, fpow, opts);
    }

    bool vanish() {
        return tcbdbvanish(self->_db);
    }
    bool copy(const char* path) {
        return tcbdbcopy(self->_db, path);
    }
    bool tranbegin() { 
        return tcbdbtranbegin(self->_db);
    }

    bool trancommit() {
        return tcbdbtrancommit(self->_db);
    }
    bool tranabort() { 
        return tcbdbtranabort(self->_db);
    }

    const char *path() {
        return tcbdbpath(self->_db);
    }
    long long rnum() { 
        return tcbdbrnum(self->_db); 
    }
    long long fsiz() {
        return tcbdbfsiz(self->_db);
    }

};

