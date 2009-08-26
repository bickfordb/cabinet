
%typemap(check) TCMAP * {
    if ($1 == NULL) { 
        PyErr_SetString(PyExc_TypeError, "Expecting a dictionary of bytestring to bytestring");
        return NULL;
    }
}

%typemap(in) (TCMAP *)
{
    $1 = NULL;
    bool valid = true;
    if (PyDict_Check($input)) {
        PyObject *key, *value;
        Py_ssize_t pos = 0;
        while (PyDict_Next($input, &pos, &key, &value)) {
            if (!PyString_Check(key)) {
                valid = false;
                break;
            }
            if (!PyString_Check(value)) { 
                valid = false;
                break;
            } 
        }
    } else { 
        valid = false; 
    }
    if (valid) { 
        $1 = tcmapnew(); 
        PyObject *key, *value;
        Py_ssize_t pos = 0;
        while (PyDict_Next($input, &pos, &key, &value)) {
            char *kbuf, *vbuf;
            Py_ssize_t ksz = 0, vsz = 0;
            PyString_AsStringAndSize(key, &kbuf, &ksz);
            PyString_AsStringAndSize(value, &vbuf, &vsz);
            tcmapput($1, kbuf, ksz, vbuf, vsz);
        }
    }
}

%typemap(freearg) TCMAP * %{
    if ($1 != NULL)
        tcmapdel($1);
%}

%typemap(newfree) TCMAP * { 
    if ($1 != NULL)
        tcmapdel($1);
}

%typemap(out) TCMAP * { 
    if ($1 == NULL) { 
        $result = Py_None;
    } else {
        tcmapiterinit($1);
        $result = PyDict_New();
        {
            while (1) {
                int ksz = 0, vsz = 0;
                const void *kbuf = tcmapiternext($1, &ksz);
                if (kbuf == NULL) 
                    break;
                const void *vbuf = tcmapget($1, kbuf, ksz, &vsz);
                PyObject *key = PyString_FromStringAndSize((const char*)kbuf, ksz);
                PyObject *val = PyString_FromStringAndSize((const char*)vbuf, vsz);
                PyDict_SetItem($result, key, val);
            }
        }
    }
}

%typemap(out) TCLIST * { 
    if ($1 == NULL) { 
        $result = Py_None;
    } else { 
        $result = PyList_New(0);
        for (int i = 0; i < tclistnum($1); i++) {
            int sz = 0;
            const void *buf = tclistval($1, i, &sz);
            PyObject *val = PyString_FromStringAndSize((const char *)buf, sz);
            PyList_Append($result, val);
        }
    }
}

%typemap(in) TCLIST * { 
    $1 = tclistnew();
    Py_ssize_t num = PyList_Size($input);
    for (Py_ssize_t i = 0; i < num; i++) {
        PyObject *obj = PyList_GetItem($input, i);
        void *buf = NULL;
        Py_ssize_t sz = 0;
        PyString_AsStringAndSize(obj, (char **)&buf, &sz);
        tclistpush($1, buf, (int)sz);
    }
}

%typemap(typecheck) TCLIST * {
    $1 = 1;
    if (!PyList_Check($input)) {
        $1 = 0;
    }
    if ($1) {
        Py_ssize_t num = PyList_Size($input);
        for (Py_ssize_t i = 0; i < num; i++) {
            if (!PyString_Check(PyList_GetItem($input, i)) {
                $1 = 0;
                break;
            }
        }
    }
}

%typemap(newfree) TCLIST * {
    if ($1 != NULL) 
        tclistdel($1);
}

%typemap(newfree) std::string * { 
    if ($1 != NULL) {
        delete $1;
    }
}

%typemap(out) std::string * { 
    if ($1 == NULL) { 
        $result = Py_None;
    } else { 
        $result = PyString_FromStringAndSize($1->c_str(), $1->length());
    }
}


