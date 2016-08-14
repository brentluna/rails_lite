require_relative 'associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_pk = through_options.primary_key
      through_fk = through_options.foreign_key
      through_table = through_options.table_name

      source_pk = source_options.primary_key
      source_fk = source_options.foreign_key
      source_table = source_options.table_name
      val = self.send(through_fk)
      result = DBConnection.execute(<<-SQL, val)
      select
      #{source_table}.*
      from
        #{through_table}
      join
        #{source_table}
      on
        #{source_table}.#{through_pk} = #{through_table}.#{source_fk}
      where
        #{through_table}.#{through_pk} = ?
      SQL
      source_options.model_class.new(result.first)
    end
  end
end
