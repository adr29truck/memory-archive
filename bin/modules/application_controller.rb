# frozen_string_literal: true

# Sequel.sqlite('./bin/db/data.db')

class ApplicationController
  # FIXME:
  # << Sequel::Model(:table)
  # DBHandler --> user
  # Sequel::Model --> user

  # Configuration
  if ENV['state'] != 'dev'
    DB = Sequel.connect(ENV['DATABASE_URL'])
  else
    DB = Sequel.sqlite('./bin/db/data.db') # TODO: sqlit3, postgresql or other
  end


  # Initializes a new instance of an object and sets provided data
  #
  # Params - Hash
  #
  # Returns instance of class with instance_variables set according to params
  def initialize(params)
    raise 'No data provided' unless params.is_a? Hash

    params = params.to_h.stringify_keys

    puts params
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
      singleton_class.send(:attr_accessor, key.to_s)
    end
    self.class.columns.each do |x|
      unless params.include?(x.to_s)
        instance_variable_set("@#{x.to_s.gsub(':', '')}", nil)
        singleton_class.send(:attr_accessor, x.to_s.gsub(':', ''))
      end
    end
  end

  #############################################################
  ##### Getter/Setters configuration ####
  #############################################################
  # Setter
  def self.set_table(symbol)
    @table = symbol
  end

  # Getter
  class << self
    attr_reader :table
  end

  # Setter
  def self.set_columns(*symbols)
    @columns = symbols
  end

  # Getter
  class << self
    attr_reader :columns
  end

  #############################################################
  ##### General methods ####
  #############################################################

  # Fetches data from the database where the conditions apply
  #
  # conditions - Hash (Conditions for fetching from db)
  # table - String (Optional table)
  #
  # Returns a array of objects
  def self.where(conditions, table = nil)
    dataset = if !table.nil?
                DB[:"#{table}"]
              elsif !self.table.nil?
                DB[:"#{self.table}"]
              else
                DB[:"#{to_s.downcase}"]
              end
    dataset.where(conditions)
  end

  # Initializes Sequel instance for provided table
  #
  # table - String (Optional table)
  #
  # Returns Sequel instance based on class table
  def self.fetch(table = nil)
    dataset = if !table.nil?
                DB[:"#{table}"]
              elsif !self.table.nil?
                DB[:"#{self.table}"]
              else
                DB[:"#{to_s.downcase}"]
              end
  end

  # Returns all elements from database table
  #
  # table - String (Optional table)
  #
  # Returns Array of elements from database
  def self.fetch_all(table = nil)
    dataset = if !table.nil?
                DB[:"#{table}"]
              elsif !self.table.nil?
                DB[:"#{self.table}"]
              else
                DB[:"#{to_s.downcase}"]
              end
    dataset.all
  end

  # Saves a instance to the database
  #
  # table - String (Optional table)
  #
  # returns nothing
  def save(table = nil)
    # Converts object to hash
    hash = {}
    instance_variables.map { |q| hash[q.to_s.gsub('@', '')] = instance_variable_get(q) }

    dataset = if !table.nil?
                DB[:"#{table}"]
              elsif !self.class.table.nil?
                DB[:"#{self.class.table}"]
              else
                DB[:"#{self.class.to_s.downcase}"]
              end

    if instance_variables.include?(:@id) && id.is_a?(Integer)
      # Object has a id and thereby is only updated
      dataset.where(id: id).update(hash)
    else
      p hash
      p self
      # Object is inserted into database
      DB.transaction do
        dataset.insert(hash)
        # Retrives the new id
        if self.class.columns.include?(:id)
          id = dataset.limit(1).order(:id).reverse
          instance_variable_set(:@id, id.first[:id])
        end
      end
    end
  end
end

class Hash
  # Loops over the keys in a hash and yields block
  #
  # block - Does something to the key
  #
  # Returns yielded result
  def transform_keys
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end

  # Converts hash keys to strings
  #
  # Returns a new hash containing stringlified keys
  def stringify_keys
    transform_keys(&:to_s)
  end

  # TODO: Add classFactory class
  def objectify(clazz)
    objects = []
    if Array.class_exists?(clazz)
      clazzer = Object.const_get(clazz)
    else
      clazzer = ClassFactory.create_class clazz.downcase.capitalize, ApplicationController
    end
    clazzer.new self
  end
end

class Array
  def objectify(clazz)
    objects = []
    if Array.class_exists?(clazz)
      clazzer = Object.const_get(clazz)
    else
      clazzer = ClassFactory.create_class clazz.downcase.capitalize, ApplicationController
    end

    each do |element|
      objects << clazzer.new(element)
    end
    objects
  end

  # Checks if a class is defined
  #
  # class_name - (String) Class name. Case sensetive
  #
  # Returns true or false
  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    klass.is_a?(Class)
  rescue NameError
    false
  end
end
