## Superclass for PAForm
class Deliverable < ApplicationRecord
  belongs_to :iteration, inverse_of: :iteration, dependent: :destroy
end
