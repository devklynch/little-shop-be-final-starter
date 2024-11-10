class AddDescriptionToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :description, :string
  end
end
