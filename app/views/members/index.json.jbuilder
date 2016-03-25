json.array!(@members) do |member|
  json.extract! member, :id, :name
  json.url member_url(member, format: :json)
end
