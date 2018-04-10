require 'active_record/relation/predicate_builder'
require 'active_record/relation/predicate_builder/array_handler'
require 'active_support/concern'

module ActiveRecord
  class PredicateBuilder # :nodoc:
    module CallWithFeature
      def call(attribute, value)
        relation = attribute.try(:relation)
        return super if relation.nil?

        if relation.is_a?(Arel::Nodes::TableAlias)
          table_name = relation.table_name
        else
          table_name = relation.name
        end

        cache = ActiveRecord::Base.connection.schema_cache
        if cache.data_source_exists? table_name
          column = cache.columns(table_name).find do |col|
            col.name.to_s == attribute.name.to_s
          end
        end

        if column && column.respond_to?(:array) && column.array
          attribute.eq(value)
        else
          super(attribute, value)
        end
      end
    end

    module ArrayHandlerPatch
      extend ActiveSupport::Concern

      included { prepend CallWithFeature }
    end
  end
end

ActiveRecord::PredicateBuilder::ArrayHandler.send(:include, ActiveRecord::PredicateBuilder::ArrayHandlerPatch)
