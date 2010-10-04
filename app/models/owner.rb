class Owner < ActiveRecord::Base
  belongs_to :user
  has_many :archives
end
