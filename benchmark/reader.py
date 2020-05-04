from pymarc import MARCReader
import time

t0 = time.time()

count = 0
with open('data/umich_created_20151120.marc', 'rb') as fh:
    reader = MARCReader(fh)
    for record in reader:
        count += 1

        if count % 1000 == 0:
            print("We have %s records" % count)


print("We have %s records" % count )

print( time.time() - t0 )
