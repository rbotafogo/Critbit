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
  attr_reader :default_proc
  attr_reader :prefix
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------
  
  def initialize(default = nil, &block)
    @default = default
    @default_proc = block
    @prefix = nil
    @java_critbit =  MCritBitTree.new(StringKeyAnalyzer.new)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def[](key)
    
    val = fetch(key)
    if (val == nil)
      val = @default
      val = @default_proc.call(self, key, val) if @default_proc
    end
    val
    
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

  def assoc(key)
    [key, fetch(key)]
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

  def default=(val)
    @default = val
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def default_proc=(proc)
    @default_proc = proc
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def delete(key)

    val = @java_critbit.remove(key)
    # key not found
    if (val == nil)
      if block_given?
        yield key
      end
      @default
    end
    val
    
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def each(prefix = nil, &block)
    cursor = EachCursor.new(&block)
    _get(cursor, prefix)
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

  def keys(prefix = nil)
    cursor = ListCursor.new(:key)
    _get(cursor, prefix).list
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def prefix=(pre)
    @prefix = pre
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

  def values(prefix = nil)
    cursor = ListCursor.new(:value)
    _get(cursor, prefix).list
  end


  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  # Methods that are not in Hash interface

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

  private
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def _get(cursor, prefix = nil)
    prefix ||= @prefix
    (prefix)? @java_critbit.traverseWithPrefix(prefix, cursor) :
      @java_critbit.traverse(cursor)
    cursor
  end

end
