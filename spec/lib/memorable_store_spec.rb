require_relative '../spec_helper'
require 'pry'

describe Memorable::Store do
  describe 'fetch' do
    let(:store) { Memorable::Store.new }
    it 'behaves like a hash with one key' do
      -> { store.fetch(:a) }.must_raise KeyError
    end

    it 'fails with two keys' do
      -> { store.fetch(:a, :b) }.must_raise KeyError
    end

    it 'succeeds if the value is present' do
      store.data[:a][:b] = 100
      store.fetch(:a, :b).must_equal 100
    end

    describe 'with a block' do
      specify 'with one key' do
        obj = Object.new
        store.fetch(:a) { obj }.must_equal obj
        store.fetch(:a) { Object.new }.must_equal obj
      end

      specify 'with multiple keys' do
        obj = Object.new
        store.fetch(:a, :b) { obj }.must_equal obj
        store.fetch(:a, :b) { Object.new }.must_equal obj
      end
    end
  end
end
