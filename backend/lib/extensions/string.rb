class String
  def arel
    Arel.sql(self)
  end
end