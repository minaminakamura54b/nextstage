require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "Ruby on Rails"
    #assert_selectメソッドでは、特定のHTMLタグが存在するかどうかをテストします
  end

  test "should get help" do
    get help_path
    assert_response :success
  end

  test "should get about" do
    get about_path
    assert_response :success
  end

  test "should get news" do
    get news_path
    assert_response :success
  end
end
