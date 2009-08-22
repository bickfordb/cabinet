%module(docstring="The table database API of Tokyo Cabinet", module="tokyocabinet") tdb
%include "std_string.i"
%include "std_map.i"
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
        this->_db = tctdbnew();
    }
    ~TDB() {
        if (this->_db) tctdbdel(_db);
    }

    bool tune(int64_t bnum, int8_t apow, int8_t fpow, uint8_t opts) {
        return tctdbtune(_db, bnum, apow, fpow, opts); 
    }

    bool setcache(int32_t rcnum, int32_t lcnum, int32_t ncnum) {
        return tctdbsetcache(_db, rcnum, lcnum, ncnum);
    }

    bool setxmsiz(long long xmsiz) {
        return tctdbsetxmsiz(_db, xmsiz);
    }

    bool open(const std::string & path, long omode) {
        return tctdbopen(_db, path.c_str(), omode);
    }

    bool close() {
        return tctdbclose(_db);
    }

    bool put(const std::string & key, StringMap & columns) {
        TCMAP *the_map = tcmapnew(); 
        StringMap::iterator i;
        for (i = columns.begin(); i != columns.end(); ++i) {
            std::string key = i->first;
            std::string val = i->second;
            tcmapput(the_map, key.c_str(), key.length(), val.c_str(), val.length());
        }
        bool result = tctdbput(_db, key.c_str(), key.length(), the_map);
        tcmapdel(the_map);
        return result;
    }
    const char *path() {
        return tctdbpath(_db);
    }

    long long rnum() { 
        return tctdbrnum(_db); 
    }

    long long fsiz() {
        return tctdbfsiz(_db);
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

    
    TCTDB *_db; 
};

%}

class TDB {
    
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
  
};

%extend TDB { 
    int __len__() { 
        return self->rnum() ;
    }
};

%pythoncode %{ 

%}
