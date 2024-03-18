class Project < ApplicationRecord
    before_create :generate_uuid_for_id

    self.table_name = 'Project'
    self.inheritance_column = nil

    belongs_to :user, optional: true
    
    def generate_uuid_for_id
        self.id ||= SecureRandom.uuid
    end
end
