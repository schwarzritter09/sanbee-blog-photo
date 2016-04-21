class Photo < ActiveRecord::Base
  has_many :tags, -> {where("count > ?", 0)}
  has_many :members, :through => :tags
  belongs_to :create_member, :class_name => "Member", :foreign_key => "create_member_id"
  
  scope :update_get, -> datetime { where('created_at > ?', datetime)}
end
