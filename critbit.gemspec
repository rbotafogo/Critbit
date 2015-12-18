# -*- coding: utf-8 -*-
require 'rubygems/platform'

require './version'


Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "A crit-bit tree is a data structure for storage of key-value pairs similar to a hash or a heap."
  
  gem.description = <<-EOF 

A crit bit tree, also known as a Binary Patricia Trie is a trie
(https://en.wikipedia.org/wiki/Trie), also called digital tree and sometimes radix tree
or prefix tree (as they can be searched by prefixes), is an ordered tree data structure
that is used to store a dynamic set or associative array where the keys are usually
strings.

Unlike a binary search tree, no node in the tree stores the key associated with that
node; instead, its position in the tree defines the key with which it is associated.
All the descendants of a node have a common prefix of the string associated with
that node, and the root is associated with the empty string. Values are normally
not associated with every node, only with leaves and some inner nodes that
correspond to keys of interest. For the space-optimized presentation
of prefix tree, see compact prefix tree.

This code is a wrapper around https://github.com/jfager/functional-critbit.

For more information go to: http://cr.yp.to/critbit.html 
EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/critbit/wiki'
  gem.license = 'MIT'

  gem.add_development_dependency('shoulda', '~> 3.5')
  gem.add_development_dependency('simplecov', '~> 0.7', [">= 0.7.1"])
  gem.add_development_dependency('yard', '~> 0.8', [">= 0.8.5.2"])

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', 'version.rb', 'config.rb', '{lib,test}/**/*.rb', 'test/**/*.csv',
                  'test/**/*.xlsx',
                  '{bin,doc,spec,vendor,target}/**/*', 
                  'README*', 'LICENSE*'] # & `git ls-files -z`.split("\0")

  gem.test_files = Dir['test/*.rb']

  gem.platform='java'

end
