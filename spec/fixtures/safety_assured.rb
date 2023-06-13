class ChangeColumnsInNotificationsNonnullable < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_reference :web_push_subscriptions, :parent
      add_reference :web_push_subscriptions, :car
      add_reference :web_push_subscriptions, :juice
    end
  end
end
