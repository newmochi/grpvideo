json.array!(@savings) do |saving|
  json.id saving.id
  json.storepath saving.storepath
  json.filename saving.video.url
  json.recdate saving.recdate
  json.title saving.title
  json.owner saving.owner
end
