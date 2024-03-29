# frozen_string_literal: true

module Trains
  module Utils
    # Combine multiple migrations into models
    module MigrationTailor
      def self.stitch(models = {}, migrations)
        migrations.each do |mig|
          case mig.modifier
          when :create_table, :create_join_table
            if models.key?(mig.table_name)
              models[mig.table_name].fields.push(*mig.fields)
            else
              models[mig.table_name] = Trains::DTO::Model.new(
                name: mig.table_name,
                fields: mig.fields,
                version: mig.version
              )
            end
          when :add_column, :add_column_with_default, :add_reference
            models[mig.table_name].fields.push(*mig.fields)
          when :ignore_column
            models[mig.table_name].ignored_columns.push(*mig.fields.map(&:name))
          when :remove_column
            column =
              models[mig.table_name].fields.find do |field|
                field.name == mig.fields.first.name
              end
            models[mig.table_name].fields.delete(column)
            models[mig.table_name].removed_columns.push(mig.fields.first.name)
          when :rename_column
            column =
              models[mig.table_name].fields.find do |field|
                field.name == mig.fields.first.name
              end
            models[mig.table_name].fields.push(
              Trains::DTO::Field.new(
                name: mig.fields.first.type.to_sym,
                type: column.type
              )
            )
            models[mig.table_name].fields.delete(column)
            models[mig.table_name].renamed_columns.push(
              Trains::DTO::Rename.new(
                from: mig.fields.first.name.to_sym, to: mig.fields.first.type.to_sym
              )
            )
          when :change_table
            mig.fields.each do |field|
              case field.type
              when :remove
                column =
                  models[mig.table_name].fields.find do |mod_field|
                    mod_field.name == field.name
                  end
                models[mig.table_name].fields.delete(column)
                models[mig.table_name].removed_columns.push(field.name)
              when :rename
                # find the field and store temporarily
                column =
                  models[mig.table_name].fields.find do |mod_field|
                    mod_field.name == field.name[0]
                  end
                # Create new field from temp with new name
                models[mig.table_name].fields.push(
                  Trains::DTO::Field.new(
                    name: field.name[1].to_sym,
                    type: column.type
                  )
                )
                # Delete the field
                models[mig.table_name].fields.delete(column)
                models[mig.table_name].renamed_columns.push(
                  Trains::DTO::Rename.new(
                    from: field.name[0], to: field.name[1]
                  )
                )
              else
                models[mig.table_name].fields.push(field)
              end
            end
          when :change_column
            # get column
            column =
              models[mig.table_name].fields.find do |field|
                field.name == mig.fields.first.name
              end
            # replace it with new column object
            models[mig.table_name].fields.delete(column)

            models[mig.table_name].fields << mig.fields.first
          else
            next
          end

        rescue NoMethodError
          next
        end

        models
      end
    end
  end
end
