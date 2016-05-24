class Tag < ActiveRecord::Base
  belongs_to :photo
  belongs_to :member
  has_one :article, through: :photo
  
  scope :update_get, -> datetime { where('updated_at > ?', datetime)}
  scope :find_by_photo, -> photo_id { where('photo_id = ?', photo_id)}
  scope :find_by_member, -> member_id { where('member_id = ?', member_id)}
end
