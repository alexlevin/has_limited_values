module ActiveRecord
  class Base
    
    def self.has_limited_values_on(field_name, options = {}, &block)
      values = options[:to]
      case values
        when Hash
          values = hash_values.keys
          select_options = self.build_select_options(field_name, values)
          hash_values = values
        when Array
          select_options = self.build_select_options(field_name, values)
          hash_values = {}
          select_options.each do |title, value|
            hash_values[value] = title
          end
        else
          raise "No values provided"
      end
      
      create_boolean_accessors = options[:with_accessors] || false
      
      class_eval(<<-EOF, __FILE__, __LINE__)
        cattr_accessor :#{field_name}_hash, :#{field_name}_values, :#{field_name}_options
        self.#{field_name}_hash = hash_values.with_indifferent_access
        self.#{field_name}_values = values
        self.#{field_name}_options = select_options

        def #{field_name}_to_s
          self.#{field_name}_hash[#{field_name}]
        end
      EOF
      
      if create_boolean_accessors
        values.each do |value|
          class_eval(<<-EOF, __FILE__, __LINE__)
            def #{field_name}_#{value}?
              self.#{field_name} == "#{value.to_s}"
            end
          EOF
        end
      end
    end
    
    private
    def self.build_select_options(field_name, values)
      options = []
      values.each do |value|
        title = I18n.t("activerecord.attributes.#{self.class_name.underscore}.#{field_name}_values.#{value}") rescue value.humanize
        options << [title, value]
      end
      options
    end
  end
end
