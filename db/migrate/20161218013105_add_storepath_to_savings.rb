class AddStorepathToSavings < ActiveRecord::Migration
  def change
    add_column :savings, :storepath, :string
  end
end
