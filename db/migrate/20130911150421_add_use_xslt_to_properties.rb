class AddUseXsltToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :use_xslt, :boolean
  end
end
