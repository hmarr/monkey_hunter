# Monkey Hunter

Find out what a Ruby library monkey patches.

## Usage

Run `monkey-hunter` followed by the name of a local gem you want to inspect.

```shell
$ monkey-hunter wasabi
I, [2014-12-31T17:35:05.065213 #92062]  INFO -- : Loading the ruby standard library
I, [2014-12-31T17:35:05.370915 #92062]  INFO -- : Loading httpi
I, [2014-12-31T17:35:05.433993 #92062]  INFO -- : Loading nokogiri
I, [2014-12-31T17:35:05.530610 #92062]  INFO -- : Taking initial snapshot
I, [2014-12-31T17:35:06.736542 #92062]  INFO -- : Loading wasabi
I, [2014-12-31T17:35:06.746281 #92062]  INFO -- : Taking final snapshot

String
  #snakecase()
    (from Wasabi::CoreExt::String)

```

## How it works

1. Load the entire Ruby standard library
2. Load all dependencies of the library in question (e.g. for 'wasabi', load
   'httpi' and 'nokogiri')
3. Loop through every class and module in the Ruby VM (using the ObjectSpace
   module), and make a record of the instance methods, singleton methods, and
   constants
4. Load the library in question (in the example above, 'wasabi')
5. Repeat step 3, taking another snapshot of the object graph
6. Diff the two object graph snapshots
7. Report what has changed!

