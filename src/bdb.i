%module bdb
%include "std_string.i"
%include "typemaps.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tcbdb.h>
#include <string>


class BDB {
    public:
    BDB() { 
        this->_db = tcbdbnew();
    }
    ~BDB() {
        if (this->_db) tcbdbdel(_db);
    }

    bool tune(long lmemb, long nmemb,
                     long long bnum, long apow, long fpow, long opts) {
        return tcbdbtune(_db, lmemb, nmemb, bnum, apow, fpow, opts); 
    }

    bool setcache(long lcnum, long ncnum) {
        return tcbdbsetcache(_db, lcnum, ncnum);
    }

    bool setxmsiz(long long xmsiz) {
        return tcbdbsetxmsiz(_db, xmsiz);
    }

    bool open(const std::string & path, long omode) {
        return tcbdbopen(_db, path.c_str(), omode);
    }
    bool close() {
        return tcbdbclose(_db);
    }

    bool put(const std::string & key, const std::string & value) {
        return tcbdbput(_db, key.c_str(), key.length(), value.c_str(), value.length());
    }

    bool putkeep(const std::string & key, const std::string & value) {
        return tcbdbputkeep(_db, key.c_str(), key.length(), value.c_str(), value.length());
    }

    bool out(const std::string & key) {
        return tcbdbout(_db, key.c_str(), key.length());
    }
    PyObject * get(const std::string & key) {
        int value_size = 0;
        void *value = tcbdbget(_db, key.c_str(), key.length(), &value_size);    
        if (value != NULL) {
            PyObject *result = PyString_FromStringAndSize((const char*) value, value_size);
            free(value);
            return result;
        } else { 
            return Py_None;
        } 
    }
    long vsiz(const std::string & key) { 
        return tcbdbvsiz(_db, key.c_str(), key.length());
    };

    long addint(const std::string & key, long num) {
        return tcbdbaddint(_db, key.c_str(), key.length(), num);
    }
    double adddouble(const std::string & key, double num) {
        return tcbdbadddouble(_db, key.c_str(), key.length(), num);
    }
    bool sync() {
        return tcbdbsync(_db);
    }

    bool optimize(TCBDB *bdb, int32_t lmemb, int32_t nmemb,
                   int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts) {
        return tcbdboptimize(_db, lmemb, nmemb, bnum, apow, fpow, opts);
    }

    bool vanish() {
        return tcbdbvanish(_db);
    }
    bool copy(const std::string & path) {
        return tcbdbcopy(_db, path.c_str());
    }
    bool tranbegin() { 
        return tcbdbtranbegin(_db);
    }

    bool trancommit() {
        return tcbdbtrancommit(_db);
    }
    bool tranabort() { 
        return tcbdbtranabort(_db);
    }

    const char *path() {
        return tcbdbpath(_db);
    }

    long long rnum() { 
        return tcbdbrnum(_db); 
    }

    long long fsiz() {
        return tcbdbfsiz(_db);
    }

    bool putcat(const std::string & key, const std::string & value) {
        return tcbdbputcat(_db, key.c_str(), key.length(), value.c_str(), value.length());
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
    private:
    TCBDB *_db; 
};

%}

class BDB {
    
    public:
    static const long TLARGE;
    static const long TDEFLATE;
    static const long TBZIP;
    static const long TTCBS;
    static const long OREADER;
    static const long OWRITER;
    static const long OCREAT;
    static const long OTRUNC;
    static const long ONOLCK;
    static const long OLCKNB;
    static const long OTSYNC;
 
    %feature("autodoc") tune;
    bool tune(long lmemb, long nmemb,
                     long long bnum, long apow, long fpow, long opts) ;
    
    %feature("autodoc") setcache;
    bool setcache(long lcnum, long ncnum);

    %feature("autodoc") setmxsiz;
    bool setxmsiz(long long xmsiz);

    %feature("autodoc") open;
    bool open(const char* path, long omode) ;

    %feature("autodoc") close;
    bool close();
    
    %apply (char *STRING, int LENGTH) { (const void *key, int key_size) };
    %apply (char *STRING, int LENGTH) { (const void *value, int value_size) };

    %feature("docstring", "Store a new record into a B+ tree database object.

Arguments:
key -- the key
value -- the value

Returns:
boolean") put;
    //bool put(const void* key, int key_size, const void* value, int value_size);
    bool put(const std::string & key, const std::string & value);

    %feature("autodoc", "Concatenate a value at the end of the existing record in a B+ tree database object.") putkeep;
    bool putkeep(const std::string & key, const std::string & value);

    %feature("docstring", "Concatenate a value at the end of the existing record in a B+ tree database object.") putcat;
    bool putcat(const std::string & key, const std::string & value);
    
    bool out(const std::string & key) ;

    PyObject * get(const std::string & key);
    
    long vsiz(const std::string & key);

    long addint(const std::string & key, long num);
    double adddouble(const std::string & key, double num) ;
    bool sync() ;

    bool optimize(TCBDB *bdb, int32_t lmemb, int32_t nmemb,
                   int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts);

    bool vanish();
    bool copy(const std::string & path);
    bool tranbegin();

    bool trancommit();
    bool tranabort();

    const char *path();
    long long rnum();
    long long fsiz();
};

