require 'memorable/version'
module Memorable
  module ClassMethods
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  private

  def memoize
    _memoized.fetch(caller_locations.first.label) do |m|
      _memoized[m] = yield
    end
  end

  def _memoized
    @_memoized ||= {}
  end
end
