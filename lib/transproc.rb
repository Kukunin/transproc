require 'transproc/version'
require 'transproc/function'
require 'transproc/functions'
require 'transproc/composer'
require 'transproc/error'
require 'transproc/store'
require 'transproc/registry'
require 'transproc/transformer'
require 'transproc/support/deprecations'

module Transproc
  Undefined = Object.new.freeze
  Transformer.container(self)
  # Function registry
  #
  # @api private
  def self.functions
    @_functions ||= {}
  end

  # Register a new function
  #
  # @example
  #   Transproc.register(:to_json, -> v { v.to_json })
  #
  #   Transproc(:map_array, Transproc(:to_json))
  #
  #
  # @return [Function]
  #
  # @api public
  def self.register(*args, &block)
    name, fn = *args
    if functions.include? name
      raise FunctionAlreadyRegisteredError, "Function #{name} is already defined"
    end
    functions[name] = fn || block
  end

  # Returns wether the collection contains registered function by its key
  #
  # @param [Symbol] key
  #
  # @return [Boolean]
  #
  def self.contain?(key)
    functions.key?(key)
  end

  # Get registered function with provided name
  #
  # @param [Symbol] name The name of the registered function
  #
  # @api private
  def self.[](name, *args)
    fn = functions.fetch(name) { raise(FunctionNotFoundError, name) }

    if args.any?
      fn.with(*args)
    else
      fn
    end
  end
end

require 'transproc/array'
require 'transproc/hash'

# Access registered functions
#
# @example
#   Transproc(:map_array, Transproc(:to_string))
#
#   Transproc(:to_string) >> Transproc(-> v { v.upcase })
#
# @param [Symbol,Proc] fn The name of the registered function or an anonymous proc
# @param [Array] args Optional addition args that a given function may need
#
# @return [Function]
#
# @api public
def Transproc(fn, *args)
  Transproc::Deprecations.announce(
    'Transproc()',
    'Define your own function registry using Transproc::Registry extension'
  )

  case fn
  when Proc then Transproc::Function.new(fn, args: args)
  when Symbol
    func = Transproc[fn, *args]
    case func
    when Transproc::Function, Transproc::Composite then func
    else Transproc::Function.new(func, args: args)
    end
  end
end
