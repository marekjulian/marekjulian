require 'test_helper'

class PortfolioCollectionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:portfolio_collections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create portfolio_collection" do
    assert_difference('PortfolioCollection.count') do
      post :create, :portfolio_collection => { }
    end

    assert_redirected_to portfolio_collection_path(assigns(:portfolio_collection))
  end

  test "should show portfolio_collection" do
    get :show, :id => portfolio_collections(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => portfolio_collections(:one).id
    assert_response :success
  end

  test "should update portfolio_collection" do
    put :update, :id => portfolio_collections(:one).id, :portfolio_collection => { }
    assert_redirected_to portfolio_collection_path(assigns(:portfolio_collection))
  end

  test "should destroy portfolio_collection" do
    assert_difference('PortfolioCollection.count', -1) do
      delete :destroy, :id => portfolio_collections(:one).id
    end

    assert_redirected_to portfolio_collections_path
  end
end
