json.array!(@photos) do |photo|
  json.extract! photo, :id, :path, :create_member_id
  json.url photo_get_photo_url(photo, format: :json)
end
