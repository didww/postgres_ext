require 'active_record/relation/predicate_builder'
require 'active_record/relation/predicate_builder/array_handler'

require 'active_support/concern'

module ActiveRecord
  class PredicateBuilder
    module ArrayHandlerPatch
      extend ActiveSupport::Concern

      included do
        def call_with_feature(attribute, value)
          column = column_from_attribute(attribute)
          if column && column.respond_to?(:array) && column.array
            attribute.eq(value)
          else
            call_without_feature(attribute, value)
          end
        end

        private def column_from_attribute(attribute)
          relation = attribute.try(:relation)
          return unless relation
          name = relation.try(:name)
          return unless name
          cache = ActiveRecord::Base.connection.schema_cache
          if cache.data_source_exists? name
            cache.columns(attribute.relation.name).detect{ |col| col.name.to_s == attribute.name.to_s }
          end
        end

        alias_method :call_without_feature, :call
        alias_method :call, :call_with_feature
      end

      module ClassMethods

      end
    end
  end
end

ActiveRecord::PredicateBuilder::ArrayHandler.send(:include, ActiveRecord::PredicateBuilder::ArrayHandlerPatch)
