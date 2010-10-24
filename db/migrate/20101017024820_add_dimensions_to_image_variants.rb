class AddDimensionsToImageVariants < ActiveRecord::Migration
  def self.up
    add_column :image_variants, :file_width, :integer, :default => 0
    add_column :image_variants, :file_height, :integer, :default => 0
  end

  def self.down
    remove_column :image_variants, :file_height
    remove_column :image_variants, :file_width
  end
end
