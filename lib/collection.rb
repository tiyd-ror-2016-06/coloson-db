class Collection < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  def values
    Number.where(collection_id: id).pluck(:value)
  end
end
