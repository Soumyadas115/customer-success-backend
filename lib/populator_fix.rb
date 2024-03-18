module Populator
    class Factory
      def rows_sql_arr
        @records.map do |record|
          quoted_attributes = record.attribute_values.map { |v| @model_class.connection.quote(v) }
          "(#{quoted_attributes.join(', ')})"
        end
      end
    end
  end