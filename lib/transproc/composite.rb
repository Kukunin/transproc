module Transproc
  # Composition of two functions
  #
  # @api private
  class Composite
    # @return [Proc]
    #
    # @api private
    attr_reader :left

    # @return [Proc]
    #
    # @api private
    attr_reader :right

    # @api private
    def initialize(left, right)
      @left = left
      @right = right
    end

    # Call right side with the result from the left side
    #
    # @param [Object] value The input value
    #
    # @return [Object]
    #
    # @api public
    def call(value)
      right.(left.(value))
    end
    alias_method :[], :call

    # @see Function#compose
    #
    # @api public
    def compose(other)
      self.class.new(self, other)
    end
    alias_method :+, :compose
    alias_method :>>, :compose

    # @see Function#to_ast
    #
    # @api public
    def to_ast
      left.to_ast << right.to_ast
    end
  end
end
