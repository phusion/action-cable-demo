require 'test_helper'

class SpreadsheetControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get spreadsheet_index_url
    assert_response :success
  end

end
