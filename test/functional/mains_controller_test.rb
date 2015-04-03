require 'test_helper'

class MainsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Main.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Main.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Main.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to main_url(assigns(:main))
  end

  def test_edit
    get :edit, :id => Main.first
    assert_template 'edit'
  end

  def test_update_invalid
    Main.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Main.first
    assert_template 'edit'
  end

  def test_update_valid
    Main.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Main.first
    assert_redirected_to main_url(assigns(:main))
  end

  def test_destroy
    main = Main.first
    delete :destroy, :id => main
    assert_redirected_to mains_url
    assert !Main.exists?(main.id)
  end
end
