require_relative '../spec_helper'
require 'pry'

describe Memorable do
  specify { Memorable::VERSION.wont_be_nil }
end
