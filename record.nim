import strutils
import field
import constant


type 
    Record* = object
        leader*: string
        fields: seq[Field]
        pos: int
        force_utf8: bool


proc toString*(r: Record): string =

    var line: string

    for field in r.fields:
        line &= field.toString() & '\n'

    return line 


proc decode_marc(marc: string): Record =

    var r: Record = Record()

    var encoding:string = "iso8859-1"

    r.leader = marc[..(LEADER_LEN-1) ]

    # echo len(r.leader)

    if r.leader[9] == 'a':
        # echo "Encoding set to utf-8"
        encoding = "utf-8"
    
    # echo fmt"Leader: {r.leader}"

    # extract the byte offset where the record data starts
    var base_address: int = parseInt(marc[12..16])

    if base_address <= 0:
        echo "Base Address not found"
    if base_address >= len(marc):
        echo "Base Address invalid"


    # echo fmt"Base Address: {base_address}"

    # extract directory, base_address-1 is used since the
    # director ends with an END_OF_FIELD byte
    var directory: string = marc[LEADER_LEN .. base_address - 2]

    # determine the number of fields in record
    if len(directory) %% DIRECTORY_ENTRY_LEN != 0:
        echo "Record Directory Invalid"

    var field_total: int = len(directory) div DIRECTORY_ENTRY_LEN

    # echo field_total



    # add fields to our record using directory offsets
    var field_count, record_count:int = 0

    while field_count < field_total:
        var entry_start = field_count * DIRECTORY_ENTRY_LEN
        var entry_end = entry_start + DIRECTORY_ENTRY_LEN
        var entry = directory[entry_start..entry_end-1]
        var entry_tag = entry[0..2]
        var entry_length = parseInt(entry[3..6])
        var entry_offset = parseInt(entry[7..11])
        var entry_data = marc[ (base_address + entry_offset) .. (base_address + entry_offset + entry_length - 2) ]
        

        var field: Field

        # echo entry_tag, entry_data
    


        var subs: seq[string]

        var subfields: seq[SubField] = @[]

        var first_indicator, second_indicator: char


        # echo entry_tag, " ", entry_tag < "010", " ", entry_tag.isDigit(), " ", entry_data

        # assume controlfields are numeric; replicates ruby-marc behavior
        if entry_tag < "010" and entry_tag.isDigit():
            field = Field(tag:entry_tag, data:entry_data)

        else:
            

            subs = entry_data.split(SUBFIELD_INDICATOR)

            # The MARC spec requires there to be two indicators in a
            # field. However experience in the wild has shown that
            # indicators are sometimes missing, and sometimes there
            # are too many. Rather than throwing an exception because
            # we can't find what we want and rejecting the field, or
            # barfing on the whole record we'll try to use what we can
            # find. This means missing indicators will be recorded as
            # blank spaces, and any more than 2 are dropped on the floor.

            # echo "Subs: ", subs            
            subs[0] = subs[0]
            if len(subs[0]) == 0:
                echo("missing indicators: %s", entry_data)
                first_indicator = ' '
                second_indicator = ' '
            elif len(subs[0]) == 1:
                echo("only 1 indicator found: %s", entry_data)
                first_indicator = subs[0][0]
                second_indicator = ' '
            elif len(subs[0]) > 2:
                echo("more than 2 indicators found: %s", entry_data)
                first_indicator = subs[0][0]
                second_indicator = subs[0][1]
            else:
                first_indicator = subs[0][0]
                second_indicator = subs[0][1]

            # echo "First: ", first_indicator, " Second: ", second_indicator

        


            for subfield in subs[1..subs.len-1]:
                var skip_bytes:int = 1

                if len(subfield) == 0:
                    continue
                
                var code:string = subfield[0..0]

                var data:string = subfield[skip_bytes..subfield.len-1]


                subfields.add( (code: code, data: data) )

            
            field = Field(tag:entry_tag, indicators: @[first_indicator, second_indicator], subfields: subfields)

        r.fields.add( field )

        field_count += 1


    return r





proc newRecord*(marc: string): Record =

    return decode_marc(marc)






        
    






