class Portfolio < ActiveRecord::Base

    belongs_to              :archive
    has_many                :portfolio_collections, :dependent => :delete_all
    has_many                :collections, :through => :portfolio_collections

end
