HOW TO RUN IT
=============
> ruby bin/demo-data -f CSV "Nebraska,Maine,North Carolina"

ASSUMPTIONS MADE
================
* There's another API that would let you request all state FIPS IDs in one call
  - given how few states there are, it might be faster to make one big call
  about all states instead of n calls based on the size of the input. It's
  likely easier on the service end as well.

* You could also use a thread pool, which I assumed would be overkill for this
  challenge.

* I assumed I should not use any third party libraries and stuck to core Ruby
  libraries.

* I assumed it was reasonable to fail upon hitting a problem with any state or
  call; the code could be reworked to dump partial results even in the face of
  errors.

* I assumed requesting the Jun2014 data - the latest - is the best thing to do.
  The code could be changed to handle which set as an option pretty trivially.

* I assumed that the order of the output does not need to match the order of
  the input. It could be made to match pretty easily.

* I assumed that duplicate entries should not produce duplicate calls.

* I assumed that every state maps to a valid FIPS ID, and that no two states
  share a FIPS ID.
