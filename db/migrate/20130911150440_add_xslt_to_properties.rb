class AddXsltToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :xslt, :string
  end
end
