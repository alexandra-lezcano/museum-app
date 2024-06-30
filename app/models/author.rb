class Author < ApplicationRecord
  has_many :pieces

  def full_name
    "#{first_name} #{last_name}"
  end
  def full_name_reversed
    "#{last_name}, #{first_name}"
  end
end
