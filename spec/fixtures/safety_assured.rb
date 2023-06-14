class ChangeColumnsInNotificationsNonnullable < ActiveRecord::Migration[5.1]
  disable_ddl_migration!

  def change
    safety_assured do
      add_reference :web_push_subscriptions, :parent
      add_reference :web_push_subscriptions, :car
      add_reference :web_push_subscriptions, :juice
    end

    safety_assured { add_reference :email_domain_blocks, :parent, null: true, default: nil }
    safety_assured { add_reference :users, :role, foreign_key: { to_table: 'user_roles', on_delete: :nullify }, index: false }
  end
end
