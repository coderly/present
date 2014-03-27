module Present
  class Exposure
    def initialize(attribute, options = {})
      @attribute = attribute
      @options = options
    end

    def call(object)
      if object.is_a? Hash
        call_single(object)
      elsif object.respond_to? :map
        object.map { |o| call_single o }
      else
        call_single(object)
      end
    end

    def call_single(object)
      value = object.is_a?(Hash) ? object[ @attribute ] : object.public_send(@attribute)

      if @options.include? :with
        klass = @options[:with]
        value = klass.new(value, env: @options[:env])
      end

      value
    end
  end
end