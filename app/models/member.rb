class Member < ActiveRecord::Base
  has_many :tags
  has_many :photos, :through => :tags
  has_many :articles
end
