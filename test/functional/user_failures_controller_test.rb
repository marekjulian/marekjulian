require 'test_helper'

class UserFailuresControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_failures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_failure" do
    assert_difference('UserFailure.count') do
      post :create, :user_failure => { }
    end

    assert_redirected_to user_failure_path(assigns(:user_failure))
  end

  test "should show user_failure" do
    get :show, :id => user_failures(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => user_failures(:one).id
    assert_response :success
  end

  test "should update user_failure" do
    put :update, :id => user_failures(:one).id, :user_failure => { }
    assert_redirected_to user_failure_path(assigns(:user_failure))
  end

  test "should destroy user_failure" do
    assert_difference('UserFailure.count', -1) do
      delete :destroy, :id => user_failures(:one).id
    end

    assert_redirected_to user_failures_path
  end
end
