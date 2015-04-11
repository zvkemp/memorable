require_relative '../spec_helper'
require 'rr'
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

  describe 'writers' do
    let(:uuid) { SecureRandom.uuid }
    
    it 'overwrites the existing memoized value' do
      original = instance.uuid
      instance.uuid = uuid
      instance.uuid.must_equal uuid
      original.wont_equal instance.uuid
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

      specify do
        instance.modified_uuid.must_include 'modified-'
        instance.modified_uuid.must_equal instance.modified_uuid
        instance.modified_uuid.wont_equal instance.uuid
      end
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

      specify do
        instance.my_unique_method.must_equal instance.my_unique_method
        instance.my_unique_method.must_include 'unique-'
      end
    end
  end
end
