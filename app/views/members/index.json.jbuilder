json.array!(@members) do |member|
  json.extract! member, :id, :name
end
