require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get projects_create_url
    assert_response :success
  end
end
