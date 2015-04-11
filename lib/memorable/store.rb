module Memorable
  class Store
    attr_reader :data

    def initialize
      @data = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    end

    def fetch(*keys, &block)
      _fetch(*keys, &block)
    end

    def []=(key, value)
      data[key] = value
    end

    private

    def lookup(*keys)
      keys.inject(data) { |current, key| current[key] }
    end

    def _fetch(*keys)
      leaf = lookup(*keys[0..-2])
      leaf.fetch(keys.last) do |k|
        if block_given?
          leaf[k] = yield
        else
          raise KeyError
        end
      end
    end
  end
end
