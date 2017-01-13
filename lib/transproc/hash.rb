require 'transproc/coercions'

module Transproc
  # Transformation functions for Hash objects
  #
  # @example
  #   require 'transproc/hash'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:symbolize_keys) >> t(:nest, :address, [:street, :zipcode])
  #
  #   fn["street" => "Street 1", "zipcode" => "123"]
  #   # => {:address => {:street => "Street 1", :zipcode => "123"}}
  #
  # @api public
  module HashTransformations
    extend Registry

    # Map all keys in a hash with the provided transformation function
    #
    # @example
    #   Transproc(:map_keys, -> s { s.upcase })['name' => 'Jane']
    #   # => {"NAME" => "Jane"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.map_keys(hash, fn)
      map_keys!(Hash[hash], fn)
    end

    # Same as `:map_keys` but mutates the hash
    #
    # @see HashTransformations.map_keys
    #
    # @api public
    def self.map_keys!(hash, fn)
      hash.keys.each { |key| hash[fn[key]] = hash.delete(key) }
      hash
    end

    # Symbolize all keys in a hash
    #
    # @example
    #   Transproc(:symbolize_keys)['name' => 'Jane']
    #   # => {:name => "Jane"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.symbolize_keys(hash)
      symbolize_keys!(Hash[hash])
    end

    # Same as `:symbolize_keys` but mutates the hash
    #
    # @see HashTransformations.symbolize_keys!
    #
    # @api public
    def self.symbolize_keys!(hash)
      map_keys!(hash, Coercions[:to_symbol].fn)
    end

    # Symbolize keys in a hash recursively
    #
    # @example
    #
    #   input = { 'foo' => 'bar', 'baz' => [{ 'one' => 1 }] }
    #
    #   t(:deep_symbolize_keys)[input]
    #   # => { :foo => "bar", :baz => [{ :one => 1 }] }
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.deep_symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), output|
        output[key.to_sym] =
          case value
          when Hash
            deep_symbolize_keys(value)
          when Array
            value.map { |item|
              item.is_a?(Hash) ? deep_symbolize_keys(item) : item
            }
          else
            value
          end
      end
    end

    # Stringify all keys in a hash
    #
    # @example
    #   Transproc(:stringify_keys)[:name => 'Jane']
    #   # => {"name" => "Jane"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.stringify_keys(hash)
      stringify_keys!(Hash[hash])
    end

    # Same as `:stringify_keys` but mutates the hash
    #
    # @see HashTransformations.stringify_keys
    #
    # @api public
    def self.stringify_keys!(hash)
      map_keys!(hash, Coercions[:to_string].fn)
    end

    # Map all values in a hash using transformation function
    #
    # @example
    #   Transproc(:map_values, -> v { v.upcase })[:name => 'Jane']
    #   # => {"name" => "JANE"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.map_values(hash, fn)
      map_values!(Hash[hash], fn)
    end

    # Same as `:map_values` but mutates the hash
    #
    # @see HashTransformations.map_values
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.map_values!(hash, fn)
      hash.each { |key, value| hash[key] = fn[value] }
      hash
    end

    # Rename all keys in a hash using provided mapping hash
    #
    # @example
    #   Transproc(:rename_keys, user_name: :name)[user_name: 'Jane']
    #   # => {:name => "Jane"}
    #
    # @param [Hash] hash The input hash
    # @param [Hash] mapping The key-rename mapping
    #
    # @return [Hash]
    #
    # @api public
    def self.rename_keys(hash, mapping)
      rename_keys!(Hash[hash], mapping)
    end

    # Same as `:rename_keys` but mutates the hash
    #
    # @see HashTransformations.rename_keys
    #
    # @api public
    def self.rename_keys!(hash, mapping)
      mapping.each { |k, v| hash[v] = hash.delete(k) if hash.has_key?(k) }
      hash
    end

    # Copy all keys in a hash using provided mapping hash
    #
    # @example
    #   Transproc(:copy_keys, user_name: :name)[user_name: 'Jane']
    #   # => {:user_name => "Jane", :name => "Jane"}
    #
    # @param [Hash] hash The input hash
    # @param [Hash] mapping The key-copy mapping
    #
    # @return [Hash]
    #
    # @api public
    def self.copy_keys(hash, mapping)
      copy_keys!(Hash[hash], mapping)
    end

    # Same as `:copy_keys` but mutates the hash
    #
    # @see HashTransformations.copy_keys
    #
    # @api public
    def self.copy_keys!(hash, mapping)
      mapping.each do |original_key, new_keys|
        [*new_keys].each do |new_key|
          hash[new_key] = hash[original_key]
        end
      end
      hash
    end

    # Rejects specified keys from a hash
    #
    # @example
    #   Transproc(:reject_keys, [:name])[name: 'Jane', email: 'jane@doe.org']
    #   # => {:email => "jane@doe.org"}
    #
    # @param [Hash] hash The input hash
    # @param [Array] keys The keys to be rejected
    #
    # @return [Hash]
    #
    # @api public
    def self.reject_keys(hash, keys)
      reject_keys!(Hash[hash], keys)
    end

    # Same as `:reject_keys` but mutates the hash
    #
    # @see HashTransformations.reject_keys
    #
    # @api public
    def self.reject_keys!(hash, keys)
      hash.reject { |k, _| keys.include?(k) }
    end

    # Accepts specified keys from a hash
    #
    # @example
    #   Transproc(:accept_keys, [:name])[name: 'Jane', email: 'jane@doe.org']
    #   # => {:name=>"Jane"}
    #
    # @param [Hash] hash The input hash
    # @param [Array] keys The keys to be accepted
    #
    # @return [Hash]
    #
    # @api public
    def self.accept_keys(hash, keys)
      accept_keys!(Hash[hash], keys)
    end

    # Same as `:accept_keys` but mutates the hash
    #
    # @see HashTransformations.accept
    #
    # @api public
    def self.accept_keys!(hash, keys)
      reject_keys!(hash, hash.keys - keys)
    end

    # Map a key in a hash with the provided transformation function
    #
    # @example
    #   Transproc(:map_value, 'name', -> s { s.upcase })['name' => 'jane']
    #   # => {"name" => "JANE"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.map_value(hash, key, fn)
      hash.merge(key => fn[hash[key]])
    end

    # Same as `:map_value` but mutates the hash
    #
    # @see HashTransformations.map_value
    #
    # @api public
    def self.map_value!(hash, key, fn)
      hash.update(key => fn[hash[key]])
    end

    # Nest values from specified keys under a new key
    #
    # @example
    #   Transproc(:nest, :address, [:street, :zipcode])[street: 'Street', zipcode: '123']
    #   # => {address: {street: "Street", zipcode: "123"}}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.nest(hash, key, keys)
      nest!(Hash[hash], key, keys)
    end

    # Same as `:nest` but mutates the hash
    #
    # @see HashTransformations.nest
    #
    # @api public
    def self.nest!(hash, root, keys)
      nest_keys = hash.keys & keys

      if nest_keys.size > 0
        child = Hash[nest_keys.zip(nest_keys.map { |key| hash.delete(key) })]
        old_nest = hash[root]
        new_nest = old_nest.is_a?(Hash) ? old_nest.merge(child) : child
        hash.update(root => new_nest)
      else
        hash.update(root => {})
      end
    end

    # Collapse a nested hash from a specified key
    #
    # @example
    #   Transproc(:unwrap, :address, [:street, :zipcode])[address: { street: 'Street', zipcode: '123' }]
    #   # => {street: "Street", zipcode: "123"}
    #
    # @param [Hash] hash
    # @param [Mixed] root The root key to unwrap values from
    # @param [Array] keys The keys that should be unwrapped (optional)
    # @param [Hash] options hash of options (optional)
    # @option options [Boolean] :prefix if true, unwrapped keys will be prefixed
    #                           with the root key followed by an underscore (_)
    #
    # @return [Hash]
    #
    # @api public
    def self.unwrap(hash, root, keys = nil, prefix: false)
      copy = Hash[hash].merge(root => Hash[hash[root]])
      unwrap!(copy, root, keys, prefix: prefix)
    end

    # Same as `:unwrap` but mutates the hash
    #
    # @see HashTransformations.unwrap
    #
    # @api public
    def self.unwrap!(hash, root, selected = nil, prefix: false)
      if nested_hash = hash[root]
        keys = nested_hash.keys
        keys &= selected if selected
        new_keys = if prefix
          keys.map do |key|
            if root.is_a?(::Symbol)
              [root, key].join('_').to_sym
            else
              [root, key].join('_')
            end
          end
        else
          keys
        end

        hash.update(Hash[new_keys.zip(keys.map { |key| nested_hash.delete(key) })])
        hash.delete(root) if nested_hash.empty?
      end

      hash
    end

    # Same as `:unwrap` but handles nil values
    #
    # If value for a specified key is nil, or there is no such key in a hash
    # `:try_unwrap` returns hash without the specified key and with no added element
    #
    # @see HashTransformations.unwrap
    #
    # @api public
    def self.try_unwrap(hash, root, keys = nil, prefix: false)
      copy = if hash[root].nil?
               hash.reject { |k, _| k == root }
             else
               Hash[hash].merge(root => Hash[hash[root]])
             end
      unwrap!(copy, root, keys, prefix: prefix)
    end

    # Same as `:try_unwrap` but mutates the hash
    #
    # @see HashTransformations.try_unwrap
    #
    # @api public
    def self.try_unwrap!(hash, root, keys = nil, prefix: false)
      hash.delete(root) unless hash[root]
      unwrap!(hash, root, keys, prefix: prefix)
    end

    # Folds array of tuples to array of values from a specified key
    #
    # @example
    #   source = {
    #     name: "Jane",
    #     tasks: [{ title: "be nice", priority: 1 }, { title: "sleep well" }]
    #   }
    #   Transproc(:fold, :tasks, :title)[source]
    #   # => { name: "Jane", tasks: ["be nice", "sleep well"] }
    #   Transproc(:fold, :tasks, :priority)[source]
    #   # => { name: "Jane", tasks: [1, nil] }
    #
    # @param [Hash] hash
    # @param [Object] key The key to fold values to
    # @param [Object] tuple_key The key to take folded values from
    #
    # @return [Hash]
    #
    # @api public
    def self.fold(hash, key, tuple_key)
      fold!(Hash[hash], key, tuple_key)
    end

    # Same as `:fold` but mutates the hash
    #
    # @see HashTransformations.fold
    #
    # @api public
    def self.fold!(hash, key, tuple_key)
      hash.update(key => ArrayTransformations.extract_key(hash[key], tuple_key))
    end

    # Splits hash to array by all values from a specified key
    #
    # The operation adds missing keys extracted from the array to regularize the output.
    #
    # @example
    #   input = {
    #     name: 'Joe',
    #     tasks: [
    #       { title: 'sleep well', priority: 1 },
    #       { title: 'be nice',    priority: 2 },
    #       {                      priority: 2 },
    #       { title: 'be cool'                 }
    #     ]
    #   }
    #   Transproc(:split, :tasks, [:priority])[input]
    #   => [
    #       { name: 'Joe', priority: 1,   tasks: [{ title: 'sleep well' }]              },
    #       { name: 'Joe', priority: 2,   tasks: [{ title: 'be nice' }, { title: nil }] },
    #       { name: 'Joe', priority: nil, tasks: [{ title: 'be cool' }]                 }
    #     ]
    #
    # @param [Hash] hash
    # @param [Object] key The key to split a hash by
    # @param [Array] subkeys The list of subkeys to be extracted from key
    #
    # @return [Array<Hash>]
    #
    # @api public
    def self.split(hash, key, keys)
      list = Array(hash[key])
      return [hash.reject { |k, _| k == key }] if list.empty?

      existing  = list.flat_map(&:keys).uniq
      grouped   = existing - keys
      ungrouped = existing & keys

      list = ArrayTransformations.group(list, key, grouped) if grouped.any?
      list = list.map { |item| item.merge(reject_keys(hash, [key])) }
      ArrayTransformations.add_keys(list, ungrouped)
    end

    # Recursively evaluate hash values if they are procs/lambdas
    #
    # @example
    #   hash = {
    #     num: -> i { i + 1 },
    #     str: -> i { "num #{i}" }
    #   }
    #
    #   t(:eval_values, 1)[hash]
    #   # => {:num => 2, :str => "num 1" }
    #
    #   # with filters
    #   t(:eval_values, 1, [:str])[hash]
    #   # => {:num => #{still a proc}, :str => "num 1" }
    #
    # @param [Hash]
    # @param [Array,Object] args Anything that should be passed to procs
    # @param [Array] filters A list of attribute names that should be evaluated
    #
    # @api public
    def self.eval_values(hash, args, filters = [])
      hash.each_with_object({}) do |(key, value), output|
        output[key] =
          case value
          when Proc
            if filters.empty? || filters.include?(key)
              value.call(*args)
            else
              value
            end
          when Hash
            eval_values(value, args, filters)
          when Array
            value.map { |item|
              item.is_a?(Hash) ? eval_values(item, args, filters) : item
            }
          else
            value
          end
      end
    end

    # Merge a hash recursively
    #
    # @example
    #
    #   input = { 'foo' => 'bar', 'baz' => { 'one' => 1 } }
    #   other = { 'foo' => 'buz', 'baz' => { :one => 'one', :two => 2 } }
    #
    #   t(:deep_merge)[input, other]
    #   # => { 'foo' => "buz", :baz => { :one => 'one', 'one' => 1, :two => 2 } }
    #
    # @param [Hash]
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.deep_merge(hash, other)
      Hash[hash].merge(other) do |_, original_value, new_value|
        if original_value.respond_to?(:to_hash) &&
           new_value.respond_to?(:to_hash)
          deep_merge(Hash[original_value], Hash[new_value])
        else
          new_value
        end
      end
    end

    # @deprecated Register methods globally
    (methods - Registry.instance_methods - Registry.methods)
      .each { |name| Transproc.register name, t(name) }
  end
end
