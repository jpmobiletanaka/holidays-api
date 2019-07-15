class Upload < ApplicationRecord
  enum status: %i[pending in_progress finished error]

  belongs_to :user

end
