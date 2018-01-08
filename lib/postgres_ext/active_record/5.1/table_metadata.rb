module ActiveRecord
  class TableMetadata
    def has_column?(column_name)
      klass && klass.columns_hash.key?(column_name.to_s) && !klass.columns_hash[column_name.to_s].array?
    end
  end
end
