require 'rom/rails/model/form/dsl'

module ROM
  module Model
    class Form
      include Equalizer.new(:params, :model, :result)

      extend ROM::ClassMacros
      extend Form::DSL

      defines :relation

      attr_reader :params, :model, :result

      delegate :model_name, :persisted?, :to_key, to: :model
      alias_method :to_model, :model

      def self.model_name
        params.model_name
      end

      def initialize(params = {}, options = {})
        @params = params
        @model  = self.class.model.new(params.merge(options.slice(*self.class.key)))
        @result = nil
        @errors =  ActiveModel::Errors.new([])
        options.each { |key, value| instance_variable_set("@#{key}", value) }
      end

      def commit!
        raise NotImplementedError, "#{self.class}#commit! must be implemented"
      end

      def save(*args)
        @result = commit!(*args)
        self
      end

      def success?
        errors.nil? || !errors.any?
      end

      def validate!
        validator = self.class::Validator.new(attributes)
        validator.validate

        @errors = validator.errors
      end

      def attributes
        self.class.params[params]
      end

      def errors
        (result && result.error) || @errors
      end
    end
  end
end
