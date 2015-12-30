Announcement
============

Critbit version 0.5.1 has been realeased.  A crit bit tree, also known as a Binary Patricia
Trie is a trie (https://en.wikipedia.org/wiki/Trie), also called digital tree and sometimes
radix tree or prefix tree (as they
can be searched by prefixes), is an ordered tree data structure that is used to store a
dynamic set or associative array where the keys are usually strings. Unlike a binary search
tree, no node in the tree stores the key associated with that node; instead, its position
in the tree defines the key with which it is associated. All the descendants of a node have
a common prefix of the string associated with that node, and the root is associated with
the empty string. Values are normally not associated with every node, only with leaves and
some inner nodes that correspond to keys of interest. For the space-optimized presentation
of prefix tree, see compact prefix tree.

[The following is from: http://cr.yp.to/critbit.html]

A crit-bit tree supports the following operations (and more!) at high speed:

  + See whether a string x is in the tree.
  + Add x to the tree.
  + Remove x from the tree.
  + Find the lexicographically smallest string in the tree larger than x, if there is one.
  + Find all suffixes of x in the tree, i.e., all strings in the tree that have x as a prefix. Of course, this can take a long time if there are many such strings, but each string is found quickly.
  
A crit-bit tree can be used as a high-speed associative array. For example, an array mapping
54 to 1, 19 to 2, 99 to 3, 85 to 4, and 88 to 5 can be stored as a crit-bit tree containing
54=1, 19=2, 99=3, 85=4, and 88=5. The smallest string in the crit-bit tree larger than 85= is
85=4.

The standard strategy for many years has been to store searchable data sets as hash tables,
in applications that need exact searches but not lexicographic searches; or as heaps, in
applications that need to search for the minimum; or as AVL trees, red-black trees, etc. in
applications that do not fit the restrictions of hash tables and heaps.

In Python, for example, the built-in "dict" data type is a hash table. Hash tables don't
provide fast access to the smallest entry, so there's also a standard "heapq" library
providing heaps. Heaps don't provide fast lookups of other entries, so there are various
add-on libraries providing AVL trees and so on. A programmer who's happy creating a "dict"
will simply do so, but then another programmer who wants fancier operations on the resulting
database has to do an expensive conversion of the "dict" to a fancier data structure.

I (D. J. Bernstein) have become convinced that this strategy should change. The revised
strategy is much simpler: there should be one fundamental set-storage type, namely a crit-bit
tree. Here's how a crit-bit tree stacks up against the competition:

A hash table supports insertion, deletion, and exact searches. A crit-bit tree supports
insertion, deletion, exact searches, and ordered operations such as finding the minimum.
Another advantage is that a crit-bit tree guarantees good performance: it doesn't have any
tricky slowdowns for unusual (or malicious) data.

A heap supports insertion, deletion, and finding the minimum. A crit-bit tree supports
insertion, deletion, finding the minimum, and exact searches, and general suffix searches.

General-purpose comparison-based structures such as AVL trees and B-trees support exactly the
same operations as a crit-bit tree. However, crit-bit trees are faster and simpler, especially
for variable-length strings. B-trees advertise a memory layout that's friendly to your disk,
but with less effort one can use a similar "clustering" organization for nodes in a crit-bit
tree.

If you're designing a programming language, imagine how much happier your programmers will be
if your basic built-in data type allows not just looking up x, but also enumerating the
strings after x in sorted order. You can't do this with hash tables. You could do it with an
AVL tree, but your operations will be simpler and faster if you use a crit-bit tree.

Critbit Interface
=================

This version of Critbit implements a very similar interface as the Hash interface with minor
modifications when it makes sense to do so.  Besides implementing the Hash interface it also
provides features for searching for keys that have a common prefix that are not possible
with hashes.

Here is an example of using Critbit:

      crit = Critbit.new

      # crit is space efficient and stores prefixes only once and can be used to
      # find only strings that match a certain prefix
      items = ["u", "un", "unh", "uni", "unj", "unim", "unin", "unio",
               "uninc", "unind", "unine", "unindd", "uninde", "unindf",
               "unindew", "unindex", "unindey", "a", "z"]

      # add items to the container
      items.each do |item|
        crit[item] = item
      end

      # Does each for all elements in the critbit
      print "["
      crit.each do |key, value|
        print "[#{key}, #{value}] "
      end
      print "]"

Prints:

      [[a, a] [u, u] [un, un] [unh, unh] [uni, uni] [unim, unim] [unin, unin] [uninc, uninc]
      [unind, unind] [unindd, unindd] [uninde, uninde] [unindew, unindew] [unindex, unindex]
      [unindey, unindey] [unindf, unindf] [unine, unine] [unio, unio] [unj, unj] [z, z] ].

Observe that all elements are printed in sorted order, this is because critbit is
naturally sorted.  This is one of the benefits of critbit over hashes.

Critbits also allow for doing prefix traversal. In the next code example the critbit is
traversed by only selecting strings that have "unin" as prefix, by passing the prefix as
argument to 'each':

      # Does each for all elements in the critbit
      print "["
      crit.each("unin") do |key, value|
        print "[#{key}, #{value}] "
      end
      print "]"

      [[unin, unin] [uninc, uninc] [unind, unind] [unindd, unindd] [uninde, uninde]
       [unindew, unindew] [unindex, unindex] [unindey, unindey] [unindf, unindf]
       [unine, unine] ].

A critbit prefix can also be set by using method 'prefix=':

      crit.prefix = "unin"

      # Does each for all elements in the critbit
      print "["
      crit.each do |key, value|
        print "[#{key}, #{value}] "
      end
      print "]"


Critbit installation and download:
==================================

  + Install Jruby
  + bundle install or manually with
  + jruby –S gem install critbit

Critbit Homepages:
==================

  + http://rubygems.org/gems/critbit
  + https://github.com/rbotafogo/critbit/wiki

Contributors:
=============

Contributors are welcome.

Critbit History:
================

  + 30/12/2015: Version 0.5.1 - Tested with jruby 9.0.4, added bundler for development
  + 22/07/2015: Version 0.5.0 – Initial release.

