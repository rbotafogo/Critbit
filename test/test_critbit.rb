# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation for educational, research, and 
# not-for-profit purposes, without fee and without a signed licensing agreement, is hereby 
# granted, provided that the above copyright notice, this paragraph and the following two 
# paragraphs appear in all copies, modifications, and distributions. Contact Rodrigo
# Botafogo - rodrigo.a.botafogo@gmail.com for commercial licensing opportunities.
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

require 'rubygems'
require 'test/unit'
require 'shoulda'

require_relative '../config'

require 'critbit'

class CritbitTest < Test::Unit::TestCase

  context "Critbit test" do

    setup do

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "create Critbit from array notation" do

      # Associates "a" to 1, "b" to 2, etc...
      crit = Critbit["a", 1, "b", 2, "c", 3, "d", 4]

      # Critbit will have the same contente as the given hash
      crit2 = Critbit["a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5]

      # Create a Cribit from another Critbit, this will do a copy
      crit3 = Critbit[crit]

      # Uses the given associations
      crit4 = Critbit[[["a", 1], ["b", 2], ["c", 3], ["d", 4], ["e", 5], ["f", 6]]]

      # This is an error... ["f"] is an illegal argumento to a Critbit
      assert_raise ( RuntimeError ) { Critbit[[["a", 1], ["b", 2], ["c", 3], ["d", 4],
                                               ["e", 5], ["f"]]] }
      # This is an error, since there are only 3 elements on the given array.
      assert_raise ( RuntimeError ) { Critbit["a", 1, 2] }
      
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "delete_if block is true" do

      crit = Critbit.new

      # crit is space efficient and stores prefixes only once and can be used to
      # find only strings that match a certain prefix
      items = ["u", "un", "unine", "uni", "unindd", "unj", "unim", "unin", "unio",
               "uninde", "uninc", "unind", "unh",  "unindf",
               "unindew", "unindex", "unindey", "a", "z"]

      # add items to the container
      items.each do |item|
        crit[item] = item
      end

      # remove all elements with key > "unind"
      crit.delete_if { |key, val| key > "unind" }

      # those are the elements left
      ok = ["u", "un", "uni", "unim", "unin", "unind", "unh",  "a"]
      
      ok.each do |item|
        assert_equal(true, crit.has_key?(item))
      end
      
      # add the items to the container again
      items.each do |item|
        crit[item] = item
      end

      crit.delete_if { |key, val| val > "unind" }
      ok.each do |item|
        assert_equal(true, crit.has_key?(item))
      end

    end
    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "return enumerator from each without block" do

      crit = Critbit.new

      # crit is space efficient and stores prefixes only once and can be used to
      # find only strings that match a certain prefix
      items = ["u", "un", "unine", "uni", "unindd", "unj", "unim", "unin", "unio",
               "uninde", "uninc", "unind", "unh",  "unindf",
               "unindew", "unindex", "unindey", "a", "z"]

      # add items to the container
      items.each do |item|
        crit[item] = item
      end

      # Enumerator
      e = crit.each
      assert_equal("a", e.next[0])
      assert_equal("u", e.next[0])

      # Enumerator with prefix
      e = crit.each("unind")
      assert_equal("unind", e.next[0])
      assert_equal("unindd", e.next[0])
      
    end
  
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "create critbit with default values" do

      # Create a new Critbit with a default_proc.  Default proc is called whenever a
      # key is searched and not found in the Critbit.  In this example, if we try to
      # access a non-existing key, the key will be added with value NaN (not a number)
      # Default_proc accepts three arguments: critbit (the container), key, value
      
      crit = Critbit.new { |h, k, val| h[k] = 0.0/0.0 }
      assert_equal(0, crit.size)

      # Since there is a default_proc, this will be called whenever the key is not present
      # in the container.  "null" is not a key, checking for crit["null"] will add the key
      # with the default NaN (0.0/0.0) value.
      assert_equal(true, crit["null"].nan?)

      # The size of the repository is now 1 since the key "null" was added.
      assert_equal(1, crit.size)
      
    end
    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "use Critbit as Hash" do
      
      crit = Critbit.new

      # add some key, value pairs to crit
      crit["hello"] = 0
      crit["there"] = 1
      crit["essa"] = 10
      crit["Essa é uma frase para armazenar"] = 100
      assert_equal(4, crit.size)
      assert_equal(0, crit["hello"])
      assert_equal(1, crit["there"])
      assert_equal(100, crit["Essa é uma frase para armazenar"])

      # fetch the key from crit
      assert_equal(0, crit.fetch("hello"))

      # remove a key, value pair from crit.  Given the key it will return the value and
      # remove the entry
      assert_equal(0, crit.delete("hello"))
      assert_equal(3, crit.size)
      assert_equal(nil, crit["hello"])
      crit.delete("not there") { |k| p "#{k} is not there" }

      assert_raise ( KeyError ) { crit.fetch("hello") }
      assert_equal("NotFound", crit.fetch("hello", "NotFound"))

      # crit also accepts complex objects
      crit["works?"] = [10, 20, 30]
      assert_equal([10, 20, 30], crit["works?"])
      assert_equal(["works?", [10, 20, 30]], crit.assoc("works?"))

      # check if keys are stored in crit
      assert_equal(true, crit.has_key?("there"))
      assert_equal(false, crit.has_key?("Not there"))

      # crit stores data in sorted order, so we can call min and max on crit
      assert_equal(["Essa é uma frase para armazenar", 100], crit.min)
      assert_equal(["works?", [10, 20, 30]], crit.max)

      # crit also allows for checking value containment
      assert_equal(true, crit.has_value?(100))
      assert_equal(true, crit.has_value?([10, 20, 30]))
      assert_equal(false, crit.has_value?("hello"))

      # Critbit implements the each method, so all methods from Enumerable can be called
      assert_equal([["Essa \u00E9 uma frase para armazenar", 100], ["essa", 10],
                    ["there", 1], ["works?", [10, 20, 30]]], crit.entries)

      p crit.flatten
      p crit.inspect

    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "use each with prefix" do

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

      # Does each for all elements in the container
      crit.each do |key, value|
        assert_equal(value, crit[key])
      end

      # Each can also filter by prefix.  Let's try prefix unin
      pre = ["unin", "uninc", "unind", "unine", "unindd", "uninde", "unindf",
             "unindew", "unindex", "unindey"]
      crit.each("unin") do |key, value|
        assert_equal(true, pre.include?(key))
      end

      # Those are not prefixed by unin
      flse = ["u", "un", "unh", "uni", "unj", "unim", "unio", "a", "z"]
      crit.each_pair("unin") do |key, value|
        assert_equal(false, flse.include?(key))
      end

      # Using unind as prefix...
      pre = ["unind", "unindd", "uninde", "unindf", "unindew", "unindex", "unindey"]
      crit.each("unind") do |key, value|
        assert_equal(true, pre.include?(key))
      end

      # sets the crit prefix.  From now on, only keys with prefix "unin" will be retrieved
      # even when the prefix is not part of the parameter list as above
      crit.prefix = "unin"

      # all unin prefix should be retrieved
      pre = ["unin", "uninc", "unind", "unine", "unindd", "uninde", "unindf",
             "unindew", "unindex", "unindey"]
      crit.each do |key, value|
        assert_equal(true, pre.include?(key))
      end

      # all keys that do not have a unin prefix are not retrieved
      flse = ["u", "un", "unh", "uni", "unj", "unim", "unio", "a", "z"]
      crit.each do |key, value|
        assert_equal(false, flse.include?(key))
      end

      assert_equal([["unin", "unin"], ["uninc", "uninc"], ["unind", "unind"],
                    ["unindd", "unindd"], ["uninde", "uninde"], ["unindew", "unindew"],
                    ["unindex", "unindex"], ["unindey", "unindey"], ["unindf", "unindf"],
                    ["unine", "unine"]], crit.entries)
      
=begin
      p crit.keys
      p crit.values
      p crit.values("unin")
      crit.clear
      p crit.values
=end

    end
    
    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "compare two critbits" do

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

      # Create a second critbit with the same content as crit
      crit2 = Critbit[crit]
      # they have the same elements
      assert_equal(true, crit.eql?(crit2))

      # If the prefix is set on a critbit, only keys with the given prefix will be
      # checkd and eql? will return false
      crit.prefix = "u"
      assert_equal(false, crit.eql?(crit2))

      # again both crit and crit2 are equal
      crit2.prefix = "u"
      assert_equal(true, crit.eql?(crit2))

      # remove the crit prefix
      crit.prefix = nil

      # create crit3 that is different from crit
      crit3 = Critbit.new
      it2 = ["u", "un", "unh", "uni", "unj", "unim", "unin", "unio",
             "uninc", "unind", "unine", "unindd", "uninde", "unindf",
             "unindew", "unindex", "unindey"]

      # add items to the container
      it2.each do |item|
        crit3[item] = item
      end

      # crit and crit3 are not eql?
      assert_equal(false, crit.eql?(crit2))
      assert_equal(false, crit2.eql?(crit))

      # but crit3 is a subset of crit with only prefix "u", so now crit and crit3
      # are eql?
      crit.prefix = "u"
      assert_equal(true, crit.eql?(crit3))
      
    end

  end

end
