#!/usr/bin/env python3

import sys

data = [ 0 for _ in range(2048) ]

def ALO(rw, imm):
    return 0x83000000 + ((rw & 0xff) << 16) + (imm & 0xffff)

def AHI(rw, imm):
    return 0x84000000 + ((rw & 0xff) << 16) + (imm & 0xffff)

def COP(rw, r1):
    return ADD(rw, r1, 0)

def ADD(rw, r1, r2):
    return 0x80000000 + ((rw & 0xff) << 16) + ((r1 & 0xff) << 8) + (r2 & 0xff)

def SUB(rw, r1, r2):
    return 0x81000000 + ((rw & 0xff) << 16) + ((r1 & 0xff) << 8) + (r2 & 0xff)

def AND(rw, r1, r2):
    return 0x82000000 + ((rw & 0xff) << 16) + ((r1 & 0xff) << 8) + (r2 & 0xff)

def RDL(rw, r1):
    return 0x90000000 + ((rw & 0xff) << 16) + ((r1 & 0xff) << 8)

def WRL(r1, r2): # data[regs[r1]] = regs[r2]
    return 0xa0000000 + ((r1 & 0xff) << 8) + (r2 & 0xff)

def DUMP():
    return 0x01000000

def FINISHED():
    return 0xff000000

def NOP():
    return 0x00000000

ip = 0

def add(ins):
    global ip
    data[ip] = ins
    ip += 1

if False:
    m = 32

    i = 0
    while i < m:
        add(ALO(1, i * 4))
        add(WRL(1, 1))
        i = i + 1

    access = list(range(m))
    for _ in range(4):
        for x in access:
            add(ALO(1, x * 4))
            add(RDL(2, 1))
            add(ADD(3, 3, 2))
    add(NOP())
    add(NOP())
    add(NOP())
    add(NOP())
    add(DUMP())
    add(FINISHED())

if False:
    access = list(range(4 * 4 * 4))
    for x in access:
        add(ALO(2, x * 4))
        add(RDL(1, 1))
        add(DUMP())
    add(FINISHED())

if True:
    step = 4 * 8
    access = [0,  2, 0 + step, 2 * step, 1, 3, 1 + step, 3 + step]
    access = [x * 4 for x in access]
    access = access * 16
    print("expect: ", hex(sum(access)), file=sys.stderr)
    print("values: ", [hex(x) for x in access], file=sys.stderr)
    
    i = 0
    for x in access:
        i += x
        print("compute: %3x" % x, hex(i), file=sys.stderr)
    
    i = 0
    while i < max(access) + 1:
        add(ALO(1, i))
        add(WRL(1, 1))
        i = i + 4
    
    for x in access:
        add(ALO(1, x))
        add(RDL(2, 1))
        add(ADD(3, 3, 2))
    
    add(NOP())
    add(NOP())
    add(NOP())
    add(NOP())
    add(DUMP())
    add(FINISHED())

if False:
    add(ALO(1, 0x1234))
    add(ALO(2, 0x0014))
    add(WRL(2, 1))

    add(NOP())
    add(NOP())
    add(NOP())
    add(NOP())
    add(DUMP())
    add(FINISHED())

for x in data:
    print("%08x" % x)
