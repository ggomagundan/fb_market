class CreateAdvertiseInfos < ActiveRecord::Migration
  def change
    create_table :advertise_infos do |t|
      t.integer :event_id
      t.string :advertise_id
      t.string :marketer_id
      t.integer :level

      t.timestamps null: false
    end
  end
end
