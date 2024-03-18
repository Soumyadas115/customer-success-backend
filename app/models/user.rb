class User < ApplicationRecord
    self.table_name = 'User'

    has_many :projects, foreign_key: 'userId'
    has_many :members, foreign_key: 'userId'
    has_many :notifications
    has_many :managed_projects, class_name:'Project', foreign_key: 'project_managerId'
    has_many :audited_projects, class_name:'Project', foreign_key: 'auditorId'
    has_many :as_client_projects, class_name:'Project', foreign_key: 'clientId'
end
