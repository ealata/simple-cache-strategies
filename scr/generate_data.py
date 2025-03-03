#!/usr/bin/env python3

for x in range(512):
    l = ""
    for i in range(4):
        #l = "%08x" % (x * 4 + i) + l
        l = "%08x" % 0 + l
    print(l)
