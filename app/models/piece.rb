class Piece < ApplicationRecord
  NOT_PUBLISHED = 0
  PUBLISHED = 1
  ARCHIVED = 2

  belongs_to :piece_collection
  belongs_to :material, optional: true
  belongs_to :author, optional: true
  validates_presence_of :name

  enum :status, { hidden: NOT_PUBLISHED, published: PUBLISHED, archived: ARCHIVED}, default: :hidden

  def self.ransackable_attributes(auth_object = nil)
    [ "description", "name" ]
  end

  def update_status!(status)
    return false unless status.in?([ NOT_PUBLISHED, PUBLISHED, ARCHIVED ])
    update!(status: status)
    true
  end


end