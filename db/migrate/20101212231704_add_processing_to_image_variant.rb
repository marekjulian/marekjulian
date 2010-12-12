class AddProcessingToImageVariant < ActiveRecord::Migration
  def self.up
    add_column :image_variants, :processing, :boolean, :default => true
  end

  def self.down
    remove_column :image_variants, :processing
  end
end
