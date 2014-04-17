module Present
  class Exposure

    def initialize(attribute, options = {})
      @attribute = attribute.freeze
      @options = options.freeze
    end

    def call(entity)
      object = entity.send(:object)
      options = entity.send(:options)
      env = options[:env]

      value = object.is_a?(Hash) ? object[ attribute ] : object.public_send(attribute)

      if value.respond_to? :map
        value.map { |v| wrap(v, env) }
      else
        wrap(value, env)
      end
    end

    private

    attr_reader :attribute, :options

    def wrap(value, env)
      if options.include? :with
        klass = options[:with]
        value = klass.new(value, env: env)
      end
      value
    end

  end
end