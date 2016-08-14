require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where_line = params.map { |k, v| "#{k} = ?" }.map(&:to_sym).join(' and ')
    results = DBConnection.execute(<<-SQL, *params.values)
    select
      *
    from
      #{self.table_name}
    where
      #{where_line}
    SQL
    parse_all(results)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
