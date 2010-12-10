class Image < ActiveRecord::Base

    belongs_to :archive
    has_many   :image_variants, :dependent => :destroy
    has_many   :image_show_views
    has_and_belongs_to_many :collections

    accepts_nested_attributes_for :image_variants, :allow_destroy => true

end
