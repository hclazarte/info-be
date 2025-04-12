require 'test_helper'

class ZonasControllerTest < ActionDispatch::IntegrationTest
  test 'should get active' do
    get zonas_active_url
    assert_response :success
  end
end
