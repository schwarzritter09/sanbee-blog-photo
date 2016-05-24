class Article < ActiveRecord::Base
  has_many :photos
  belongs_to :member
end
