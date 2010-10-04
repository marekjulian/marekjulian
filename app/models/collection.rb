class Collection < ActiveRecord::Base

    belongs_to              :archive
    has_and_belongs_to_many :images
    has_many                :portfolio_collections, :dependent => :delete_all
    has_many                :portfolios, :through => :portfolio_collections

end
