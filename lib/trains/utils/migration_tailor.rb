module Trains
  module Utils
    module MigrationTailor
      def self.stitch(migrations)
        models = {}

        migrations.each do |mig|
          case mig.modifier
          when :create_table
            models[mig.table_name] = {}
            models[mig.table_name] = Trains::DTO::Model.new(
              name: mig.table_name,
              fields: mig.fields,
              version: mig.version
            )
          when :add_column
            models[mig.table_name].fields.push(*mig.fields)
          when :remove_column
            column =
              models[mig.table_name].fields.find do |field|
                field.name == mig.fields.first.name
              end
            models[mig.table_name].fields.delete(column)
          when :change_table
          # TODO: handle renaming columns
          when :change_column
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
