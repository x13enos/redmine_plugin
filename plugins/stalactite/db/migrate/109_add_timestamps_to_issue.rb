class AddTimestampsToIssue < ActiveRecord::Migration
  def change
    add_column :issues, :started_at, :datetime
    add_column :issues, :finished_at, :datetime
  end
end
