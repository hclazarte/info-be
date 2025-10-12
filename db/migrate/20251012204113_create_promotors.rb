class CreatePromotors < ActiveRecord::Migration[7.0]
  def change
    create_table :promotors do |t|

      t.timestamps
    end
  end
end
