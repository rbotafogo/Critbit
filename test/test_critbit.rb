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

    should "create critbit container" do
      
      crit = Critbit.new
      
      crit["hello"] = 0
      crit["there"] = 1
      crit["essa"] = 10
      crit["Essa é uma frase para armazenar"] = 100
      assert_equal(0, crit["hello"])
      assert_equal(1, crit["there"])
      assert_equal(100, crit["Essa é uma frase para armazenar"])
      crit["works?"] = [10, 20, 30]
      assert_equal([10, 20, 30], crit["works?"])
      assert_equal(["works?", [10, 20, 30]], crit.assoc("works?"))
      assert_equal(5, crit.size)
      assert_equal(false, crit.has_key?("Not there"))
      assert_equal(["Essa é uma frase para armazenar", 100], crit.min)
      assert_equal(["works?", [10, 20, 30]], crit.max)
      assert_equal(true, crit.has_value?(100))
      assert_equal(true, crit.has_value?([10, 20, 30]))
      assert_equal(false, crit.has_value?("hello"))

      p crit.get_all

      items = ["u", "un", "unh", "uni", "unj", "unim", "unin", "unio",
               "uninc", "unind", "unine", "unindd", "uninde", "unindf",
               "unindew", "unindex", "unindey", "a", "z"]

      items.each do |item|
        crit[item] = item
      end

      crit.each do |key, value|
        p "key: #{key}, value: #{value}"
      end

      p crit.any? { |key, value| key == "uni" }
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
