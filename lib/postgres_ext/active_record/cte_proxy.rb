class CTEProxy
  include ActiveRecord::Querying
  include ActiveRecord::Sanitization::ClassMethods
  include ActiveRecord::Reflection::ClassMethods

  attr_accessor :reflections
  attr_reader :connection, :arel_table

  delegate :column_names,       :columns_hash,            :model_name,
           :attribute_alias?,   :aggregate_reflections,   :instantiate,
           :type_for_attribute, :relation_delegate_class, :arel_attribute,
           :primary_key,        :ignored_columns,         :current_scope,
           :current_scope=,     :has_attribute?,          :enforce_raw_sql_whitelist,
           to: :@model

  def initialize(name, model)
    @name = name
    @arel_table = Arel::Table.new(name)
    @model = model
    @connection = model.connection
    @_reflections = {}
  end

  def name
    @name
  end

  def table_name
    name
  end

  private

  def reflections
    @_reflections
  end

  alias _reflections reflections
end
