require 'test_helper'

class Cm::CollectionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cm_collections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collection" do
    assert_difference('Cm::Collection.count') do
      post :create, :collection => { }
    end

    assert_redirected_to collection_path(assigns(:collection))
  end

  test "should show collection" do
    get :show, :id => cm_collections(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => cm_collections(:one).id
    assert_response :success
  end

  test "should update collection" do
    put :update, :id => cm_collections(:one).id, :collection => { }
    assert_redirected_to collection_path(assigns(:collection))
  end

  test "should destroy collection" do
    assert_difference('Cm::Collection.count', -1) do
      delete :destroy, :id => cm_collections(:one).id
    end

    assert_redirected_to cm_collections_path
  end
end
