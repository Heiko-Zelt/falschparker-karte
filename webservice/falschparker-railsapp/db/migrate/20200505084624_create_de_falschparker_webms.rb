class CreateDeFalschparkerWebms < ActiveRecord::Migration[6.0]
  def change
    create_table :de_falschparker_webms do |t|
      t.text :name
      t.integer :ewz
      t.smallint :taten
      t.real :pro_mil
      t.smallint :kategorie
      t.geometry :way
      t.smallint :admin_level
    end
  end
end
