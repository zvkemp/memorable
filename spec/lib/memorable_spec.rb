require_relative '../spec_helper'
require 'securerandom'

describe Memorable do
  class DumDum
    include Memorable

    def uuid
      memoize { SecureRandom.uuid }
    end

    def uuid=(str)
      memoize!(:uuid) { str }
    end

    def guid
      memoize(:some_key) { SecureRandom.guid }
    end
  end

  specify { Memorable::VERSION.wont_be_nil }

  let(:instance) { DumDum.new }

  describe 'lazy readers' do
    it 'is instance-idempotent' do
      instance.uuid.must_equal instance.uuid
    end

    it 'is globally unique' do
      DumDum.new.uuid.wont_equal instance.uuid
    end
  end

  describe 'falsey values' do
    class DumDum
      def store_falsey
        memoize do
          increment_counter
          false
        end
      end

      def increment_counter
        @counter ||= 0
        @counter += 1
      end

      attr_reader :counter
    end

    specify 'falsey values are cached' do
      instance.store_falsey.must_equal false
      instance.counter.must_equal 1
      instance.store_falsey.must_equal false
      instance.counter.must_equal 1
    end
  end

  describe 'writers' do
    let(:uuid) { SecureRandom.uuid }
    
    it 'overwrites the existing memoized value' do
      original = instance.uuid
      instance.uuid = uuid
      instance.uuid.must_equal uuid
      original.wont_equal instance.uuid
    end

    describe 'methods with arguments' do
      class DumDum
        def prepend_uuid(str)
          memoize([:prepend_uuid, str]) { "#{str}-#{SecureRandom.uuid}" }
        end
      end

      specify { instance.prepend_uuid('hello').wont_equal instance.prepend_uuid('world') }
      specify { instance.prepend_uuid('hello').must_equal instance.prepend_uuid('hello') }
    end
  end

  describe 'class methods' do
    class ClassyDumDum
      include Memorable
      memoize(:uuid) { SecureRandom.uuid }
    end

    let(:instance) { ClassyDumDum.new }

    describe 'memoize with proc' do
      specify do
        instance.uuid.wont_be_nil
        instance.uuid.must_equal instance.uuid
      end
    end

    describe 'a proc with instance methods' do
      class ClassyDumDum
        memoize(:modified_uuid) { modify(SecureRandom.uuid) }

        def modify(obj)
          "modified-#{obj}"
        end
      end

      specify { instance.modified_uuid.must_include 'modified-' }
      specify { instance.modified_uuid.must_equal instance.modified_uuid }
      specify { instance.modified_uuid.wont_equal instance.uuid }
    end

    describe 'a proc with arguments' do
      class ClassyDumDum
        memoize(:prepend_with_proc) { |str| "#{str}-#{SecureRandom.uuid}" }
      end

      specify { instance.prepend_with_proc('proc').must_equal instance.prepend_with_proc('proc') }
      specify { instance.prepend_with_proc('proc').wont_equal instance.prepend_with_proc('lambda') }
    end

    describe 'memoize an existing method' do
      class ClassyDumDum
        def my_unique_method
          concat('unique', SecureRandom.uuid)
        end

        def concat(*strs)
          strs.join('-')
        end

        memoize :my_unique_method
      end

      specify { instance.my_unique_method.must_equal instance.my_unique_method }
      specify { instance.my_unique_method.must_include 'unique-'}
    end

    describe 'methods with arguments' do
      class ClassyDumDum
        def prepend_uuid(str)
          "#{str}-#{SecureRandom.uuid}"
        end

        memoize :prepend_uuid
      end

      specify { instance.prepend_uuid('hello').wont_equal instance.prepend_uuid('world') }
      specify { instance.prepend_uuid('hello').must_equal instance.prepend_uuid('hello') }
    end
  end
end
