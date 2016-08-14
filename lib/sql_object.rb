require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns || (
    cols = DBConnection.execute2(<<-SQL)
    select
      *
    from
      #{self.table_name}
    SQL
    @columns = cols.first.map(&:to_sym) )
  end

  def self.finalize!
    self.columns.each do |col|
      define_method("#{col}") do
        attributes[col]
      end
      define_method("#{col}=") do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    units = DBConnection.execute(<<-SQL)
      select
        #{self.table_name}.*
      from
        #{self.table_name}
      SQL
    self.parse_all(units)
  end

  def self.parse_all(results)
    results.map { |unit| self.new(unit) }

  end

  def self.find(id)
    unit = DBConnection.execute(<<-SQL, id)
      select
        *
      from
        #{self.table_name}
      where
        id = ?
    SQL
    return nil if unit.first.nil?
    self.new(unit.first)
  end

  def initialize(params = {})
    params.each do |k, v|
      k = k.to_sym
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k)
      self.send("#{k}=", v)
    end

  end

  def attributes
    @attributes ||= {}

  end

  def attribute_values
    self.class.columns.map  { |el| self.send("#{el}") }
  end

  def insert
    col_names = self.class.columns.join(",")
    question_marks = (["?"] * self.class.columns.length).join(",")
    DBConnection.execute(<<-SQL, *attribute_values)
      insert into
        #{self.class.table_name} (#{col_names})
      values
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id

  end

  def update
    cols = self.class.columns.map { |col| "#{col} = ?"}.join(",")
    DBConnection.execute(<<-SQL, *attribute_values, id)
    update
      #{self.class.table_name}
    set
      #{cols}
    where
      id = ?
    SQL
  end

  def save
    if self.id
      update
    else
      insert
    end 
  end
end
