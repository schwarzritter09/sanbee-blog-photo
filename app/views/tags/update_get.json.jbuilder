json.array!(@tags) do |tag|
  json.extract! tag, :id, :photo_id, :member_id, :count
end
