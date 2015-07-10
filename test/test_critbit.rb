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

    should "create critbit with default values" do

      # Create a new Critbit with a default_proc.  Default proc is called whenever a
      # key is searched and not found in the Critbit.  In this example, if we try to
      # access a non-existing key, the key will be added with value NaN (not a number)
      # Default_proc accepts three arguments: critbit (the container), key, value
      
      crit = Critbit.new { |h, k, val| h[k] = 0.0/0.0 }
      assert_equal(0, crit.size)
      assert_equal(true, crit["null"].nan?)
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

      # remove a key, value pair from crit.  Given the key it will return the value and
      # remove the entry
      assert_equal(0, crit.delete("hello"))
      assert_equal(3, crit.size)
      assert_equal(nil, crit["hello"])
      crit.delete("not there") { |k| p "#{k} is not there" }

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
               
    end

    #-------------------------------------------------------------------------------------
    #
    #-------------------------------------------------------------------------------------

    should "Filter by prefix" do

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

      crit.each do |key, value|
        assert_equal(value, crit[key])
      end

      assert_equal(true, crit.any? { |key, value| key == "uni" })

      p crit.entries
      p crit.include?(["a", "a"])
      
      p crit.get_all
      p crit.get_all("uni")
      p crit.keys
      p crit.values
      p crit.values("unin")
      crit.clear
      p crit.values

    end
    
  end

end
