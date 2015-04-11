# Memorable

[![Build Status](https://travis-ci.org/zvkemp/memorable.svg)](https://travis-ci.org/zvkemp/memorable)

Provides an easy means to memoize expensive-to-compute values. Unlike the standard `@value ||= do_something...`,
Memorable can save and retrieve `nil` and `false` values, and memoize methods with arguments.

*This in the early stages, use at your own risk.*

### Usage:

Include `Memorable` in your class.

#### As a class method

With an existing method (recommended; this automatically keeps a seperate entry
for each unique set of arguments given to the method):


```ruby
class MyClass
  include Memorable

  def my_method(*args)
    puts ':my_method called'
    args.reverse
  end
  memoize :my_method
end

instance = MyClass.new
instance.my_method(1, 2, 3) 
#=> :my_method called
#=> [3, 2, 1]
instance.my_method(100, 99)
#=> :my_method called
#=> [99, 100]
instance.my_method(1, 2, 3)
#=> [3, 2, 1]
```

With a proc (use this in lieu of an instance method). The proc is evaluated in the
instance's context, so any other instance methods are available within:

```ruby
class MyClass
  include Memorable
  memoize(:full_name) do |last_name| 
    "#{first_name} #{last_name}"
  end

  def first_name
    'z'
  end
end

instance = MyClass.new
instance.full_name('k') #=> 'z k'
instance.full_name('k') #=> 'z k'
instance.full_name('m') #=> 'z m'
```

#### As an instance method

If you need more fine-grained control over which arguments should
be included in the memoized cache key, use the instance method `memoize`.


Using an argument for the cache, then ignoring it on future calls.
This will be stored under the name of the method (in this case, :my_method):

```ruby
def my_method(arg)
  memoize { [arg] }
end
```

You can optionally supply a cache key (e.g., for values depending on arguments):

```ruby
def my_method(arg)
  memoize([:my_method, arg]) { [arg] }
end
```

For memoized getters that need an accompanied setter, use the bang method:

```ruby
def my_value=(val)
  memoize! { val }
end
```

`memoize!` also supports the custom-key syntax.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'memorable', github: 'zvkemp/memorable'
```

And then execute:

    $ bundle

## Contributing

1. Fork it ( https://github.com/zvkemp/memorable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
