module ActiveRecord
  module Querying
    delegate :with, :ranked, to: :all

    def from_cte(name, expression)
      cte_proxy = CTEProxy.new(name, self)
      relation = ActiveRecord::Relation.new(
        cte_proxy,
        table: cte_proxy.arel_table,
        predicate_builder: expression.predicate_builder
      )
      relation.with name => expression
    end
  end
end
