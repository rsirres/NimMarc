import ../reader
import ../record
import times
import logging

var logger* = newConsoleLogger(fmtStr="[$time] - $levelname: ")
addHandler(logger)

let t0 = cpuTime()

var r = newReader("../data/umich_created_20151120.marc")

for record in iter(r):
    echo record.toString()

echo "CPU time [s] ", cpuTime() - t0