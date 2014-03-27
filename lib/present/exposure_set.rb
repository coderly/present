require 'present/exposure'

module Present
  class ExposureSet

    attr_reader :entity_classes

    def initialize(entity_classes)
      @entity_classes = entity_classes
    end

    def [](name)
      entity_classes.each do |klass|
        if klass == Entity
          return Exposure.new(name)
        elsif klass.exposures.include?(name)
          return klass.exposures[name]
        end
      end
    end

  end
end