import streams
import strutils
import strformat
import logging


import record
import constant


type
  Reader* = object
    file_path*: string
    current_chunk: seq[byte]


proc newReader*(file_path: string) : Reader =

    return Reader(file_path: file_path)


iterator iter*(r: var Reader): Record =
    
    var 
        s = openFileStream(r.file_path)
        first5: TaintedString
        current_chunk = ""
        length: int
        last_char: char

    while not s.atEnd():

        first5 = s.readStr(5)

        length = parseInt(first5)

        current_chunk = s.readStr(length - 5)

        last_char = current_chunk[^1]

        if last_char != END_OF_RECORD:
            error(fmt"Expected end of record delimiter. Received: {last_char}")
        else:
            let r: Record = newRecord(marc= first5 & current_chunk)

            yield r