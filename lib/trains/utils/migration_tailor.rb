module Trains
  module Utils
    module MigrationTailor
      def self.stitch(migrations)
        models = {}

        migrations.each do |mig|
          if mig.modifier == :create_table
            models[mig.table_name] = {}
            models[mig.table_name][:fields] = mig.fields
          elsif mig.modifier == :add_column
            models[mig.table_name][:fields].push(*mig.fields)
          elsif mig.modifier == :remove_column
            column =
              models[mig.table_name].fields.find do |field|
                field.name == mig.fields.first.name
              end
            models[mig.table_name].fields.delete(column)
          elsif mig.modifier == :change_table
            # TODO: handle removing columns
            # TODO: handle renaming columns
          elsif mig.modifier == :change_column
            # get column
            column =
              models[mig.table_name].fields.find do |field|
                field.name == mig.fields.first.name
              end
            # replace it with new column object
            models[mig.table_name].fields.delete(column)

            models[mig.table_name].fields << mig.fields.first
          end
        end

        models
      end
    end
  end
end
