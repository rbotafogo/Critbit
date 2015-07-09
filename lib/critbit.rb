# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require 'java'
require_relative 'env'

class Decision
  include org.ardverk.collection.Cursor

end

##########################################################################################
#
##########################################################################################

class EachCursor
  include org.ardverk.collection.Cursor

  attr_reader :key
  attr_reader :value

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def initialize(&block)
    @block = block
  end
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------
  
  def select(entry)
    @block.call(entry.getKey(), entry.getValue())
    Decision::CONTINUE
  end
  
end

##########################################################################################
#
##########################################################################################

class EntryListsCursor
  include org.ardverk.collection.Cursor

  attr_reader :klist
  attr_reader :vlist

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def initialize
    @klist = Array.new
    @vlist = Array.new
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------
  
  def select(entry)
    @klist << entry.getKey()
    @vlist << entry.getValue()
    Decision::CONTINUE
  end
  
end

##########################################################################################
#
##########################################################################################

class ListCursor
  include org.ardverk.collection.Cursor

  attr_reader :list
  attr_reader :type

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def initialize(type)

    if (type != :key && type != :value)
      raise "Illegal type #{type}"
    end
    
    @type = type
    @list = Array.new
    
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def select(entry)
    @list << ((@type == :key)? entry.getKey() : entry.getValue())
    Decision::CONTINUE
  end
  
end


##########################################################################################
#
##########################################################################################

class Critbit
  include_package "io.prelink.critbit"
  include_package "org.ardverk.collection"
  include Enumerable
  
  attr_reader :java_critbit
  attr_reader :default
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------
  
  def initialize(default = nil, depth = 16)
    @default = nil
    # @java_critbit = CritBit.create1D(depth)
    @java_critbit =  MCritBitTree.new(StringKeyAnalyzer.new)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def clear
    @java_critbit.clear
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def each(&block)
    cursor = EachCursor.new(&block)
    @java_critbit.traverse(cursor)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def get_all(prefix = nil)
    cursor = EntryListsCursor.new
    _get(cursor, prefix)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def keys(prefix = nil)
    cursor = ListCursor.new(:key)
    _get(cursor, prefix).list
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def values(prefix = nil)
    cursor = ListCursor.new(:value)
    _get(cursor, prefix).list
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def size
    @java_critbit.size()
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def print_tree
    @java_critbit.printTree()
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def has_key?(key)
    @java_critbit.containsKey(key)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def has_value?(val)
    @java_critbit.containsValue(val)
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def min
    @java_critbit.min
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def max
    @java_critbit.max
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def[]=(key, val)
    key = key.to_s if key.is_a? Symbol
    @java_critbit.put(key, val)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def fetch(key)
    key = key.to_s if key.is_a? Symbol
    @java_critbit.get(key)
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def[](key)
    fetch(key)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def assoc(key)
    [key, fetch(key)]
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  private
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def _get(cursor, prefix = nil)
    (prefix)? @java_critbit.traverseWithPrefix(prefix, cursor) :
      @java_critbit.traverse(cursor)
    cursor
  end

end
