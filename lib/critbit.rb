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

require_relative '../config'

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
  
  # Critbit[ key, value, ... ] → new_hash
  #
  # Critbit[ [ [key, value], ... ] ] → new_hash
  #
  # Critbit[ object ] → new_hash
  #
  # Creates a new critbit populated with the given objects.
  #
  # Similar to the literal hash { key => value, ... }. In the first form, keys and values
  # occur in pairs, so there must be an even number of arguments.
  # 
  # The second and third form take a single argument which is either an array of
  # key-value pairs or an object convertible to a hash.
  #
  # @param args [Args] list of arguments in any of the above formats
  # @return a new Critbit

  def self.[](*args)

    crit = Critbit.new
    
    if args.size == 1
      
      if ((args[0].is_a? Hash) || (args[0].is_a? Critbit))
        args[0].each do |k, v|
          crit[k] = v
        end
      elsif (args[0].is_a? Array)
        args[0].each do |key_pair|
          if ((key_pair.is_a? Array) && (key_pair.size == 2))
            crit[key_pair[0]] = key_pair[1]
          else
            raise "Illegal argument for Critbit #{key_pair}"
          end
        end
      else
        raise "illegal argument for Critbit"
      end
      
      return crit
      
    end
    
    if (args.size % 2 != 0)
      raise "odd number of arguments for Critbit"
    else
      i = 0
      begin
        crit[args[i]] = args[i+1]
        i += 2
      end while i < args.size
    end

    return crit
    
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.try_convert(arg)
    
  end
  
  # new → new_critbit
  #
  # new(obj) → new_critbit
  #
  # new {|critbit, key| block } → new_critbit
  #
  # Returns a new, empty critbit. If this critbit is subsequently accessed by a key
  # that doesn’t correspond to a critbit entry, the value returned depends on the
  # style of new used to create the critbit. In the first form, the access returns
  # nil. If obj is specified, this single object will be used for all default values.
  # If a block is specified, it will be called with the critbit object and the key,
  # and should return the default value. It is the block’s responsibility to store
  # the value in the critbit if required.
  # @param default [Default] the default return value if the key is not found
  # @param block [Block] the default block to be executed if key is not found
  # @return a new critbit
  
  def initialize(default = nil, &block)
    @default = default
    @default_proc = block
    @prefix = nil
    @java_critbit =  MCritBitTree.new(StringKeyAnalyzer.new)
  end

  # Element Reference—Retrieves the value object corresponding to the key object. If
  # not found, returns the default value (see Hash::new for details).
  # @param key (key) the key to be retrieved
  # @return the value reference by this key or the default value or result of executing
  # the default_proc

  def[](key)
    
    val = retrieve(key)
    if (val == nil)
      val = @default
      val = @default_proc.call(self, key, val) if @default_proc
    end
    val
    
  end

  # Associates the value given by value with the key given by key.
  # @param key [Key] the key element
  # @param val [Value] the value associated with the key
  # @return the value associated with the key

  def[]=(key, val)
    key = key.to_s if key.is_a? Symbol
    @java_critbit.put(key, val)
  end

  alias store :[]=
  
  # Searches through the critbit comparing obj with the key using ==. Returns the
  # key-value pair (two elements array) or nil if no match is found. See
  # Array#assoc.
  # @param key [Key] the key to search for
  # @return Array with two elements [key, value]

  def assoc(key)
    [key, retrieve(key)]
  end

  # Removes all key-value pairs from critbit

  def clear
    @java_critbit.clear
  end

  # Returns the default value, the value that would be returned by critbit if key did
  # not exist in critbit. See also Critbit::new and Critbit#default=
  # @param val [Value] the default value to return

  def default=(val)
    @default = val
  end
  
  # Sets the default proc to be executed on each failed key lookup.
  # @param proc [Proc] the Proc to set as default_proc

  def default_proc=(proc)
    @default_proc = proc
  end
  
  # Deletes the key-value pair and returns the value from critbit whose key is equal to
  # key. If the key is not found, returns the default value. If the optional code block
  # is given and the key is not found, pass in the key and return the result of block.
  # @param key [Key]
  # @return the value, the default value, or the result of applying the default block
  # to key

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

  # Deletes every key-value pair from hsh for which block evaluates to true.
  # 
  # If no block is given, an enumerator is returned instead.

  def delete_if(prefix = nil, &block)
    
    if block_given?
      cursor = Critbit::DeleteCursor.new(self, true, &block)
      _get(cursor, prefix)
    else
      to_enum(:each, prefix)
    end
    
  end

  alias reject! :delete_if
    
  # Calls block once for each key in critbit, passing the key-value pair as parameters.
  #
  # If no block is given, an enumerator is returned instead.

  def each(prefix = nil, &block)

    if block_given?
      cursor = Critbit::EachCursor.new(&block)
      _get(cursor, prefix)
    else
      to_enum(:each, prefix)
    end
    
  end

  alias each_pair :each

  
  # Calls block once for each key in critbit, passing the key as a parameter.
  #
  # If no block is given, an enumerator is returned instead.
                     
  def each_key(prefix = nil, &block)
    
    if block_given?
      cursor = Critbit::EachKeyCursor.new(&block)
      _get(cursor, prefix)
    else
      to_enum(:each, prefix)
    end

  end

  # Calls block once for each value in critbit, passing the value as a parameter.
  #
  # If no block is given, an enumerator is returned instead.
                     
  def each_value(prefix = nil, &block)
    
    if block_given?
      cursor = Critbit::EachValueCursor.new(&block)
      _get(cursor, prefix)
    else
      to_enum(:each, prefix)
    end

  end

  # Returns true if critbit contains no key-value pairs.
  
  def empty?
    @size == 0
  end

  
  def eql?(other)

    cr1 = each
    cr2 = other.each
    
    begin
      p1 = cr1.next
      p2 = cr2.next
      if ((p1[0] != p2[0]) || (p1[1] != p2[1]))
        return false
      end
    rescue StopIteration
      break
    end while true

    i = 0
    begin
      cr1.next
    rescue StopIteration
      i += 1
    end

    begin
      cr2.next
    rescue StopIteration
      i += 1
    end

    return false if i != 2
    
    return true
    
  end
  
  # Returns a value from the critbit for the given key. If the key can’t be found,
  # there are several options: With no other arguments, it will raise an KeyError exception;
  # if default is given, then that will be returned; if the optional code block is
  # specified, then that will be run and its result returned.

  def fetch(key, default = nil, &block)
    
    key = key.to_s if key.is_a? Symbol
    res = @java_critbit.get(key)

    if (res == nil)
      if (default != nil)
        return default
      elsif (block_given?)
        block.call(key)
      else
        raise KeyError, "key '#{key}' not found"
      end
    end
    res
    
  end

  # Returns a new array that is a one-dimensional flattening of this critbit. That is, for
  # every key or value that is an array, extract its elements into the new array.  The
  # optional level argument determines the level of recursion to flatten if the value is
  # a hash.  If value is an Array it will call array.flatten
  
  def flatten(level = nil)

    res = Array.new
    each do |key, value|
      res << key
      case value
      when (Array || Hash || Critbit)
        (level)? res.concat(value.flatten(level)) : res.concat(value.flatten)
      else
        (value.respond_to?(:flatten))? res << value.flatten : res << value
      end
    end
    res
    
  end
  
  # Returns true if the given key is present in critbit

  def has_key?(key)
    @java_critbit.containsKey(key)
  end

  # Returns true if the given key is present in critbit. Identical to has_key?

  alias include? :has_key?
  alias member? :has_key?
  alias key? :has_key?
  
  # Returns true if the given value is present for some key in critbit.

  def has_value?(val)
    @java_critbit.containsValue(val)
  end

  # Return the contents of this critbit as a string.
  
  def inspect
    
    res = "{"
    each do |key, value|
      res << "\"#{key}\"=>#{value},"
    end
    res[-1] = "}"
    return res
    
  end

  # Return the contents of this critbit as a string.

  alias to_s :inspect

  # Returns a new critbit created by using critbit’s values as keys, and the keys as
  # values.
  
  def invert
    
    crit = Critbit.new
    each do |key, value|
      crit[value.to_s] = key
    end
    crit
    
  end

  # Deletes every key-value pair from critbit for which block evaluates to false.
  
  def keep_if(prefix = nil, &block)

    if block_given?
      cursor = Critbit::DeleteCursor.new(self, false, &block)
      _get(cursor, prefix)
    else
      to_enum(:each, prefix)
    end
    
  end

  alias select! :keep_if
  
  # Returns the key of an occurrence of a given value. If the value is not found,
  # returns nil.

  def key(val)
    
    each do |key, value|
      return key if (value == val)
    end
    return nil
    
  end

  # Returns a new array populated with the keys from this critbit

  def keys(prefix = nil)
    cursor = Critbit::ListCursor.new(:key)
    _get(cursor, prefix).list
  end

  # Returns a new critbit containing the contents of other_critbit and the contents
  # of critbit. If no block is specified, the value for entries with duplicate keys will be
  # that of other_critbit. Otherwise the value for each duplicate key is determined by
  # calling the block with the key, its value in critbit and its value in other_critbit.

  def merge(other_critbit, &block)

    crit = Critbit[self]
    if (block_given?)
      other_critbit.each do |key, value|
        value = block.call(key, self[key], value) if has_key?(key)
        crit[key] = value
      end
    else
      other_critbit.each do |key, value|
        crit[key] = value
      end
    end
    crit
      
  end

  alias update :merge
  
  # Returns a new critbit containing the contents of other_critbit and the contents
  # of critbit. If no block is specified, the value for entries with duplicate keys will be
  # that of other_critbit. Otherwise the value for each duplicate key is determined by
  # calling the block with the key, its value in critbit and its value in other_critbit.

  def merge!(other_critbit, &block)

    if (block_given?)
      other_critbit.each do |key, value|
        value = block.call(key, self[key], value) if has_key?(key)
        self[key] = value
      end
    else
      other_critbit.each do |key, value|
        self[key] = value
      end
    end
    self
      
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def prefix=(pre)
    @prefix = pre
  end
  
  # Searches through the critbit comparing obj with the value using ==. Returns the first
  # key-value pair (two-element array) that matches. See also Array#rassoc.

  def rassoc(obj)

    each do |key, value|
      return [key, value] if obj == value
    end
    nil
    
  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def size
    @java_critbit.size()
  end

  alias length :size
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def values(prefix = nil)
    cursor = Critbit::ListCursor.new(:value)
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
  # Merges the two critbits. Should be significantly faster than method merge.
  #------------------------------------------------------------------------------------

  def put_all(other_critbit)
    @java_critbit.putAll(other_critbit.java_critbit)
  end
  
  #------------------------------------------------------------------------------------
  # Removes the key value pair from the critbit.  If no key is found, nil is returned.
  #------------------------------------------------------------------------------------

  def remove(key)
    @java_critbit.remove(key)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  private
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def retrieve(key)
    key = key.to_s if key.is_a? Symbol
    @java_critbit.get(key)
  end
  
  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def _get(cursor, prefix = nil)
    prefix ||= @prefix
    (prefix)? @java_critbit.traverseWithPrefix(prefix, cursor) :
      @java_critbit.traverse(cursor)
    cursor
  end

  ##########################################################################################
  #
  ##########################################################################################

  class Cursor
    include org.ardverk.collection.Cursor
    
    attr_reader :key
    attr_reader :value

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------
    
    def initialize(&block)
      @block = block
    end

  end

  ##########################################################################################
  #
  ##########################################################################################
  
  class EachCursor < Cursor
    
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
  
  class EachKeyCursor < Cursor
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------
    
    def select(entry)
      @block.call(entry.getKey())
      Decision::CONTINUE
    end
    
  end

  ##########################################################################################
  #
  ##########################################################################################
  
  class EachValueCursor < Cursor
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------
    
    def select(entry)
      @block.call(entry.getValue())
      Decision::CONTINUE
    end
    
  end
  
  ##########################################################################################
  #
  ##########################################################################################
  
  class DeleteCursor < Cursor

    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------
    
    def initialize(critbit, t_val = true, &block)
      @critbit = critbit
      @t_val = t_val
      super(&block)
    end
    
    #------------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------------
    
    def select(entry)
      @critbit.delete(entry.getKey()) if (@block.call(entry.getKey(),
                                                      entry.getValue()) == @t_val)
      Decision::CONTINUE
    end
    
  end

  ##########################################################################################
  #
  ##########################################################################################
  
  class ListCursor < Cursor
    
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
  
end
