#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import re

def main():
    strLoc   = input("Please input the path XML data:\n")
    strFirst = input("Please input the coordinates of starting point(comma or space seperated):\n")
    strLast  = input("Please input the coordinates of end point(comma or space seperated):\n")

    rawCoord = [float(i) for i in re.findall("[^ |,]+",strLoc)]

    i = 2
    while (i<len(rawCoord)):
        rawCoord[i] = rawCoord[i]+rawCoord[i-2]
        i = i+1

    rawFirst  = rawCoord[0:2]
    rawLast   = rawCoord[len(rawCoord)-2:len(rawCoord)]
    realFirst = [float(i) for i in re.findall("[^ |,]+",strFirst)]
    realLast  = [float(i) for i in re.findall("[^ |,]+",strLast)]

    coord_x = [realFirst[0]+(realLast[0]-realFirst[0])/(rawLast[0]-rawFirst[0])*(rawCoord[i]-rawFirst[0]) for i in range(0,len(rawCoord),2)]
    coord_y = [realFirst[1]+(realLast[1]-realFirst[1])/(rawLast[1]-rawFirst[1])*(rawCoord[i]-rawFirst[1]) for i in range(1,len(rawCoord),2)]

    f=open("svgExportXY.dat","w")
    
    i = 0
    while (i<len(coord_x)):
        f.write("\t".join([str(coord_x[i]),str(coord_y[i]),"\n"]))
        i = i+1
    f.close()

if __name__ == "__main__":
    main()
