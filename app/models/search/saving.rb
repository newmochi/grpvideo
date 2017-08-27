# == Schema Information
#
# Table name: savings
#
#  id            :integer          not null, primary key
#  recdate       :date
#  title         :string
#  owner         :string
#  video         :string
#  note          :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Search::Saving < Search::Base
  ATTRIBUTES = %i(
    title
    owner
    video
    note
  )
  attr_accessor(*ATTRIBUTES)

  def matches
    t = ::Saving.arel_table
    results = ::Saving.all
    results = results.where(contains(t[:title], title)) if title.present?
    results = results.where(contains(t[:owner], owner)) if owner.present?
    results = results.where(contains(t[:video], video)) if video.present?
    results = results.where(contains(t[:note], note)) if note.present?
    results
  end
end
