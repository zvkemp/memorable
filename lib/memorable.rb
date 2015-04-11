require 'memorable/version'

module Memorable
  module ClassMethods

    # Usage:
    #
    # With an existing method (recommended; this keeps a seperate entry
    # for each unique set of arguments given to the method).
    #   def my_method(*args)
    #     args.reverse
    #   end
    #   memoize :my_method
    #
    # With a proc:
    #
    #   memoize(:some_proc) { |str| str.upcase }
    #
    # If you need more fine-grained control over which arguments should
    # be included in the memoized cache key, use the instance method `memoize`.
    def memoize(sym, &block)
      instance_eval do
        if block_given?
          define_method(sym) do |*args|
            memoize([sym] + args) { instance_exec(*args, &block) }
          end
        else
          old_method = :"_nm_#{sym}"
          alias_method old_method, sym
          memoize(sym) { |*args| send(old_method, *args) }
        end
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  private

  # If the value alread exists, return it.
  # Otherwise, execute the block, store the value, and return it.
  #
  # Usage:
  # 
  # Using an argument for the cache, then ignoring it on future calls.
  # This will be stored under the name of the method (in this case, :my_method).
  #
  #   def my_method(arg)
  #     memoize { [arg] }
  #   end
  #
  # You can optionally supply a cache key (e.g., for values depending on arguments):
  #
  #   def my_method(arg)
  #     memoize([:my_method, arg]) { [arg] }
  #   end
  #
  def memoize(key = nil)
    key ||= caller_locations.first.label.to_sym
    _memoized.fetch(key) do |m|
      _memoized[m] = yield
    end
  end

  # Execute the block and store the value even if it already exists.
  # Useful for writer methods.
  def memoize!(key = nil)
    key ||= caller_locations.first.label.to_sym
    _memoized[key] = yield
  end

  def _memoized
    @_memoized ||= {} 
  end
end
