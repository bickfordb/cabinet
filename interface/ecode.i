
%{
class ECODE { 
    public:
    static const long ESUCCESS = 0;
    static const long ETHREAD = 1;
    static const long EINVALID = 2;
    static const long ENOFILE = 3;
    static const long ENOPERM = 4;
    static const long EMETA = 5;
    static const long ERHEAD = 6;
    static const long EOPEN = 7;
    static const long ECLOSE = 8;
    static const long ETRUNC = 9;
    static const long ESYNC = 10;
    static const long ESTAT = 11;
    static const long ESEEK = 12;
    static const long EREAD = 13;
    static const long EWRITE = 14;
    static const long EMMAP = 15;
    static const long ELOCK = 16;
    static const long EUNLINK = 17;
    static const long ERENAME = 18;
    static const long EMKDIR = 19;
    static const long ERMDIR = 20;
    static const long EKEEP = 21;
    static const long ENOREC = 22;
    static const long EMISC = 9999;

    long ecode() { 
        return -1; 
    }

    const char* errmsg(long ecode=-1) {
        return "";
    };
};

%}

class ECODE { 
    public:
    static const long ESUCCESS;
    static const long ETHREAD;
    static const long EINVALID;
    static const long ENOFILE;
    static const long ENOPERM;
    static const long EMETA;
    static const long ERHEAD;
    static const long EOPEN;
    static const long ECLOSE;
    static const long ETRUNC;
    static const long ESYNC;
    static const long ESTAT;
    static const long ESEEK;
    static const long EREAD;
    static const long EWRITE;
    static const long EMMAP;
    static const long ELOCK;
    static const long EUNLINK;
    static const long ERENAME;
    static const long EMKDIR;
    static const long ERMDIR;
    static const long EKEEP;
    static const long ENOREC;
    static const long EMISC;

    %feature("docstring", "Get the error code for the last operation

Returns
integer, one of `TCESUCCESS' for success, `TCETHREAD' for threading error,
`TCEINVALID' for invalid operation, `TCENOFILE' for file not found, `TCENOPERM'
for no permission, `TCEMETA' for invalid meta data, `TCERHEAD' for invalid
record header, `TCEOPEN' for open error, `TCECLOSE' for close error, `TCETRUNC'
for trunc error, `TCESYNC' for sync error, `TCESTAT' for stat error, `TCESEEK'
for seek error, `TCEREAD' for read error, `TCEWRITE' for write error, `TCEMMAP'
for mmap error, `TCELOCK' for lock error, `TCEUNLINK' for unlink error,
`TCERENAME' for rename error, `TCEMKDIR' for mkdir error, `TCERMDIR' for rmdir
error, `TCEKEEP' for existing record, `TCENOREC' for no record found, and
`TCEMISC' for miscellaneous error.
") ecode;
    long ecode();

    %feature("docstring", "Get the error message by error code or the last
error message for this database.

Arguments
ecode -- int, the error code.  if -1, use the last error code.  defaults to -1.

Returns
string, the last error message.
") errmsg;
    const char* errmsg(long ecode=-1);
};

