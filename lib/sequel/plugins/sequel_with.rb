class Array

  def with(*assocs)
    data = self
    res = []
    merge_data = {}
    data.each {|row|
      assocs.each do |assoc|
        merge_data[assoc] = row.send(assoc).values
      end
      res << row.values.merge!(merge_data)
    }
    return res
  end

end
