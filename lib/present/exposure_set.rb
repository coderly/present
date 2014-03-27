require 'present/exposure'

module Present
  class ExposureSet

    attr_reader :entity_class

    def initialize(entity_class)
      @entity_class = entity_class
    end

    def [](name)
      if entity_class.exposures.include? name
        entity_class.exposures[name]
      else
        entity_class.ancestors.each do |klass|
          if klass == Entity
            break Exposure.new(name)
          elsif klass.exposures.include?(name)
            klass.exposures[name]
          end
        end
      end
    end

  end
end