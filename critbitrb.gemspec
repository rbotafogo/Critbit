# -*- coding: utf-8 -*-
require 'rubygems/platform'

require_relative 'version'


Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "A crit-bit tree is a data structure for storage of key-value pairs similar to a hash or a heap."
  
  gem.description = <<-EOF 

A crit-bit tree for a nonempty prefix-free set S of bit strings has an external node for each
string in S; an internal node for each bit string x such that x0 and x1 are prefixes of strings
in S; and ancestors defined by prefixes. The internal node for x is compressed: one simply stores
the length of x, identifying the position of the critical bit (crit bit) that follows x.

Each internal node in a pure crit-bit tree is stored as three components:

Left: A pointer to the left child node, if that node is internal; otherwise the string at the
left child node.
Length: An integer, the crit-bit position.
Right: A pointer to the right child node, if that node is internal; otherwise the string at
the right child node.

For more information go to: http://cr.yp.to/critbit.html 
EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/critbit/wiki'
  gem.license = 'BSD 2-clause'

  gem.add_dependency('jrubyfx',[">= 1.1.1"])
  gem.add_development_dependency('shoulda')
  gem.add_development_dependency('simplecov', [">= 0.7.1"])
  gem.add_development_dependency('yard', [">= 0.8.5.2"])
  gem.add_development_dependency('kramdown', [">= 1.0.1"])

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', 'version.rb', 'config.rb', '{lib,test}/**/*.rb', 'test/**/*.csv',
                  'test/**/*.xlsx',
                  '{bin,doc,spec,vendor,target}/**/*', 
                  'README*', 'LICENSE*'] # & `git ls-files -z`.split("\0")

  gem.test_files = Dir['test/*.rb']

  gem.platform='java'

end
