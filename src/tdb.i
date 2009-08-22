%module(docstring="The table database API of Tokyo Cabinet", module="tokyocabinet") tdb
%include "std_string.i"
%include "tcmaps.i"
%include "typemaps.i"

%{
#define SWIG_FILE_WITH_INIT
#include <tctdb.h>
#include <string>
#include <map>

using namespace std;
typedef std::map<std::string, std::string> StringMap;
typedef std::pair<std::string, std::string> StringPair;

class TDBQuery;
class TDB;

class TDB {
    public:
    TDB() { 
        _db = tctdbnew();
    }
    ~TDB() {
        if (_db != NULL) tctdbdel(_db);
    }

    TCTDB *_db; 
};

%}

class TDB {
};

%extend TDB { 
    int __len__() { 
        return tctdbrnum(self->_db);
    }
    bool tune(int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts) {
        return tctdbtune(self->_db, bnum, apow, fpow, opts); 
    }

    bool setcache(int32_t rcnum, int32_t lcnum, int32_t ncnum) {
        return tctdbsetcache(self->_db, rcnum, lcnum, ncnum);
    }

    bool setxmsiz(long long xmsiz) {
        return tctdbsetxmsiz(self->_db, xmsiz);
    }

    bool open(const std::string & path, long omode) {
        return tctdbopen(self->_db, path.c_str(), omode);
    }

    bool close() {
        return tctdbclose(self->_db);
    }

    bool put(const std::string & key, TCMAP *columns) {
        return tctdbput(self->_db, key.c_str(), key.length(), columns);
    }

    %newobject get;
    TCMAP *get(const std::string & key) {
        return tctdbget(self->_db, key.c_str(), key.length());
    }

    const char *path() {
        return tctdbpath(self->_db);
    }

    long long rnum() { 
        return tctdbrnum(self->_db); 
    }

    long long fsiz() {
        return tctdbfsiz(self->_db);
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

%}
