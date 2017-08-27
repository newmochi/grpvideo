json.array!(@savings) do |saving|
  json.extract! saving, :id, :recdate, :title, :owner, :note, :video
  json.url saving_url(saving, format: :json)
end
