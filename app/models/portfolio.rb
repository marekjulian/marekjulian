class Portfolio < ActiveRecord::Base

    belongs_to              :archive
    has_many                :portfolio_collections, :dependent => :destroy
    has_many                :collections, :through => :portfolio_collections

end
