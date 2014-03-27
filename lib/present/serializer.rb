module Present
  class Serializer

    def serialize(object)
      if object.respond_to? :serializable_hash
        object.serializable_hash
      elsif object.is_a? Array
        object.map { |o| serialize(o) }
      elsif object.respond_to?(:to_ary)
        serialize( object.to_ary )
      else
        object
      end
    end

  end
end