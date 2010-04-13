"""basic BDB benchmark"""
import time

from cabinet import bdb
import os

N = 1000000
print bdb

if os.path.exists('users.tcb'):
    os.unlink('users.tcb')
users = bdb.BDB()
users.open('./users.tcb', users.OCREAT | users.OREADER | users.OWRITER)
s = 'x' * 64

t0 = time.time()
for i in xrange(N):
    key = str(i)
    users.put(key, s)
t1 = time.time()
users.close()
t2 = time.time()

print "N =", N
print N / (t1 - t0), "/sec w/o close"
print N / (t2 - t0), "/sec w/ close" 
