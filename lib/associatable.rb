require_relative 'searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.class_name.underscore.downcase + 's'
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name.to_s}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase
    }.merge(options)

    defaults.keys.each do |key|
      self.send("#{key}=", defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      primary_key: :id,
      foreign_key: "#{self_class_name.to_s.downcase}_id".to_sym,
      class_name: name.to_s.singularize.camelcase
    }.merge(options)

    defaults.keys.each do |key|
      self.send("#{key}=", defaults[key])
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      f_key = self.send(options.foreign_key)
      p_key = options.primary_key
      options.model_class.where(p_key => f_key).first
    end


  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      p_key = self.send(options.primary_key)
      f_key = options.foreign_key

      options.model_class.where(f_key => p_key)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
