class ChangeColumnsInNotificationsNonnullable < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_reference :web_push_subscriptions, :parent
      add_reference :web_push_subscriptions, :car
      add_reference :web_push_subscriptions, :juice
    end

    safety_assured { add_reference :email_domain_blocks, :parent, null: true, default: nil }
  end
end
