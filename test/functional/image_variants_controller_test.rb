require 'test_helper'

class ImageVariantsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:image_variants)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create image_variant" do
    assert_difference('ImageVariant.count') do
      post :create, :image_variant => { }
    end

    assert_redirected_to image_variant_path(assigns(:image_variant))
  end

  test "should show image_variant" do
    get :show, :id => image_variants(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => image_variants(:one).id
    assert_response :success
  end

  test "should update image_variant" do
    put :update, :id => image_variants(:one).id, :image_variant => { }
    assert_redirected_to image_variant_path(assigns(:image_variant))
  end

  test "should destroy image_variant" do
    assert_difference('ImageVariant.count', -1) do
      delete :destroy, :id => image_variants(:one).id
    end

    assert_redirected_to image_variants_path
  end
end
