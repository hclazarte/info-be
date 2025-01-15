require "test_helper"

class CiudadesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get ciudades_show_url
    assert_response :success
  end

  test "should get by_client_ip" do
    get ciudades_by_client_ip_url
    assert_response :success
  end

  test "should get index" do
    get ciudades_index_url
    assert_response :success
  end
end
