import strutils
import strformat
import constant


type
    SubField* = tuple
        code, data: string
        

    Field* = object
        tag*: string
        data*: string
        indicators*: seq[char]
        subfields*: seq[SubField]


proc is_control_field*(f: Field): bool = 

    return f.tag < "010" and f.tag.isDigit()


proc toString*(f: Field): string =
    
    var text, temp: string

    temp = f.data.replace(" ", "\\")
    
    if f.is_control_field():
        text = fmt"={f.tag}  {temp}"
    else:
        text = fmt"={f.tag}  "
        for indicator in f.indicators:
            if indicator in {' ', '\\'}:
                text &= "\\"
            else:
                text &= indicator
        for subfield in f.subfields:
            text &= fmt"${subfield.code}{subfield.data}"

    return text


