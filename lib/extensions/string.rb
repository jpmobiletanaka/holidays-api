class String
  def to_sql
    Arel.sql(self)
  end
end