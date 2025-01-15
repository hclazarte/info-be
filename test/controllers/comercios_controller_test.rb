require "test_helper"

class ComerciosControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    get comercios_search_url
    assert_response :success
  end
end
