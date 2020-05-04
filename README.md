# Marc21 Parser for Nim Lang

Implementation of a marc21 parse for nimlang. It is heavily based on [pymarc](https://gitlab.com/pymarc/pymarc) as nim and python are so similar.

Some toy benchmarks on OSX with large marc files show that this implementation is (unsurprisingly) 3-4x faster than pymarc.


## Basic Usage Example

1. Save the following code snippet in file: `my_reader.nim`

``` nim
import reader
import record

var r = newReader("<path_to_marc>/my_file.marc")

for record in iter(r):
    echo record.toString()
```

2. Run the cmd in terminal/cmd:
``` bash
nim c -r my_reader.nim
```

## Looking for marc file to test this library ?

``` bash
cd data
wget https://www.lib.umich.edu/files/open-access-marc/umich_created_20151120.marc.gz
```

## TODO

- [] Add simple cli
- [] Support different encodings (e.g. latin-1)
- [] Support marc8 encoding
- [] Support XML serialization
- [] Support JSON serialization
- [] Support (sub-)field access like [marc-x](https://github.com/ubleipzig/marcx)
