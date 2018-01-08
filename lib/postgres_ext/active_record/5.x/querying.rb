module ActiveRecord::Querying
  delegate :with, :ranked, to: :all

  class ProxyTable < SimpleDelegator
    def initialize(table, name)
      @table = table
      @name = name
      super(table)
    end

    def arel_attribute(column)
      # Rewrite arel attribute to have a table alias only for common table expressions
      arel_attr = @table.arel_attribute(column)
      arel_attr.relation = arel_attr.relation.dup
      arel_attr.relation.table_alias = @name
      arel_attr
    end
  end

  class ProxyPredicateBuilder < ActiveRecord::PredicateBuilder
    def initialize(existing_predicate_builder, name=nil)
      if existing_predicate_builder.is_a? ActiveRecord::PredicateBuilder
        @existing_predicate_builder = existing_predicate_builder
        super(ProxyTable.new(existing_predicate_builder.table, name))
      else
        super(existing_predicate_builder)
      end
    end
  end

  def from_cte(name, expression)
    cte_proxy = CTEProxy.new(name, self)
    relation = ActiveRecord::Relation.new cte_proxy, cte_proxy.arel_table, ProxyPredicateBuilder.new(expression.predicate_builder, name)
    relation.with name => expression
  end
end
