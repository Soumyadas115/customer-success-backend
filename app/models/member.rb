class Member < ApplicationRecord
    before_create :generate_uuid_for_id

    self.table_name = 'Member'

    belongs_to :user, foreign_key: 'userId'
    belongs_to :project, foreign_key: 'projectId'

    def generate_uuid_for_id
        self.id ||= SecureRandom.uuid
    end
end
