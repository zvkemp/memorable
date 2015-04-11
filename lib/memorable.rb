require 'memorable/version'
module Memorable
  module ClassMethods
    def memoize(sym, &block)
      instance_eval do
        if block_given?
          define_method(sym) do |*args|
            memoize(sym) { instance_exec(*args, &block) }
          end
        else
          old_method = :"_nm_#{sym}"
          alias_method old_method, sym
          memoize(sym) {|*args| send(old_method, *args) }
        end
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  private

  def memoize(sym = nil)
    sym ||= caller_locations.first.label.to_sym
    _memoized.fetch(sym) do |m|
      _memoized[m] = yield
    end
  end

  # Execute the block and store the value even if it already exists.
  # Useful for writer methods.
  def memoize!(sym = nil)
    sym ||= caller_locations.first.label.to_sym
    _memoized[sym] = yield
  end

  def _memoized
    @_memoized ||= {}
  end
end
