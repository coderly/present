module Present
  class Exposure

    attr_reader :attribute, :options

    def initialize(attribute, options = {})
      @attribute = attribute.freeze
      @options = options.freeze
    end

    def call(object)
      value = object.is_a?(Hash) ? object[ attribute ] : object.public_send(attribute)

      if value.is_a? Hash
        wrap(value)
      elsif value.respond_to? :map
        value.map { |v| wrap(v) }
      else
        wrap(value)
      end
    end

    def wrap(value)
      if options.include? :with
        klass = options[:with]
        value = klass.new(value, env: options[:env])
      end
      value
    end

  end
end