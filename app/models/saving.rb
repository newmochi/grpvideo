class Saving < ActiveRecord::Base
  validates :owner, :video, :presence => true
  mount_uploader :video, VideoUploader
end
