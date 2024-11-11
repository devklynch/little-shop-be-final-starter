class AddCodeToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :code, :string
  end
end
