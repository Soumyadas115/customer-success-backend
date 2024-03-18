class Audit < ApplicationRecord
    before_create :generate_uuid_for_id

    self.table_name = 'Audit'

    belongs_to :project, foreign_key: 'projectId'

    def generate_uuid_for_id
        self.id ||= SecureRandom.uuid
    end
end