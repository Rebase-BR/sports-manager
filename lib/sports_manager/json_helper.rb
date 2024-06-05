# frozen_string_literal: true

module SportsManager
  module JsonHelper
    def as_json(_options = nil)
      instance_variables.each_with_object({}) do |var, hash|
        key = var.to_s.delete('@').to_sym
        value = instance_variable_get(var)
        hash[key] = JsonHelper.convert_value(value)
      end
    end

    def self.deep_symbolize_keys(object)
      case object
      when Hash
        object.each_with_object({}) do |(k, v), result|
          key = begin
            k.to_sym
          rescue StandardError
            k
          end
          result[key] = deep_symbolize_keys(v)
        end
      when Array
        object.map { |v| deep_symbolize_keys(v) }
      else
        object
      end
    end

    def self.convert_value(value)
      case value
      when Hash
        value.transform_keys(&:to_sym).transform_values { |v| convert_value(v) }
      when Array
        value.map { |v| convert_value(v) }
      else
        value.respond_to?(:as_json) ? value.as_json : value
      end
    end

    def self.convert_custom_object(object)
      object.instance_variables.each_with_object({}) do |var, hash|
        key = var.to_s.delete('@').to_sym
        hash[key] = convert_value(object.instance_variable_get(var))
      end
    end
  end
end

class Hash
  def as_json(_options = nil)
    transform_keys(&:to_s).transform_values do |value|
      value.respond_to?(:as_json) ? value.as_json : value
    end
  end

  def deep_symbolize_keys
    SportsManager::JsonHelper.deep_symbolize_keys(self)
  end
end

class Array
  def as_json(_options = nil)
    map do |value|
      value.respond_to?(:as_json) ? value.as_json : value
    end
  end

  def deep_symbolize_keys
    SportsManager::JsonHelper.deep_symbolize_keys(self)
  end
end

class Symbol
  def as_json(_options = nil)
    to_s
  end
end

class Numeric
  def as_json(_options = nil)
    self
  end
end

class String
  def as_json(_options = nil)
    self
  end
end

class TrueClass
  def as_json(_options = nil)
    self
  end
end

class FalseClass
  def as_json(_options = nil)
    self
  end
end

class NilClass
  def as_json(_options = nil)
    self
  end
end

class Time
  def as_json(_options = nil)
    xmlschema(3)
  end
end

class Object
  def as_json(options = nil)
    if respond_to?(:attributes)
      attributes.as_json(options)
    else
      instance_variables.each_with_object({}) do |var, hash|
        key = var.to_s.delete('@').to_sym
        value = instance_variable_get(var)
        hash[key] = SportsManager::JsonHelper.convert_value(value)
      end
    end
  end
end
