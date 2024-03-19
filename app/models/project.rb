class Project < ApplicationRecord
    before_create :generate_uuid_for_id

    self.table_name = 'Project'
    self.inheritance_column = nil

    has_many :projects, foreign_key: 'userId'
    belongs_to :project_manager, class_name: 'User', optional: true
    belongs_to :auditor, class_name: 'User', optional: true
    belongs_to :client, class_name: 'User', optional: true

    has_many :members, foreign_key: 'projectId'
    has_many :audits, foreign_key: 'projectId'
    has_many :milestones, foreign_key: 'projectId'
    has_many :risks, foreign_key: 'projectId'
    has_many :stakeholders, foreign_key: 'projectId'
    has_many :moms, foreign_key: 'projectId'
    has_many :sprints, foreign_key: 'projectId'
    has_many :versions, foreign_key: 'projectId'
    has_many :updates, foreign_key: 'projectId'
    has_many :resources, foreign_key: 'projectId'


    def generate_uuid_for_id
        self.id ||= SecureRandom.uuid
    end
end
