class Collection < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  def values
    Number.where(collection_id: id).pluck(:value)
  end

  def add n
    Number.create!(collection_id: id, value: n)
  end
end
