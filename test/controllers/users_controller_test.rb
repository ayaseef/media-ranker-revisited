# frozen_string_literal: true
require 'test_helper'

describe UsersController do
  #Tests written for Oauth.
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root path" do
      user = users(:dan)

      expect {
        perform_login(user)
      }.wont_change "User.count"

      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
      expect(flash[:notice]).must_equal "Logged in as returning user #{user.username}"
    end

    it "creates an account for a new user and redirects to the root route" do
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

      expect {
        perform_login(user)
      }.must_differ "User.count", 1

      must_redirect_to root_path
      expect(session[:user_id]).must_equal(User.find_by(provider: user.provider,
        uid: user.uid, email: user.email).id)
        expect(flash[:notice]).must_equal "Logged in as new user #{user.username}"

    end

    it "will handle a request with invalid information" do
      user = User.new(provider: "github", uid: nil, username: nil, email: nil)
      expect {
        perform_login(user)
      }.wont_change "User.count"

      # you can either respond with a bad request or redirect and give a flash notice
      # Option 1
      # must_respond_with :bad_request

      # Option 2
      must_redirect_to root_path
      expect(flash[:error]).must_equal ["Could not create new user account username: [\"can't be blank\"]"]
      expect(session[:user_id]).must_equal nil
    end
  end

  describe "logout" do
    it "will log out a logged in user" do
      user = users(:dan)
      perform_login(user)

      post logout_path

      must_redirect_to root_path
      expect(session[:user_id]).must_equal nil
      expect(flash[:notice]).must_equal "Successfully logged out"
    end

    it "will redirect back and give a flash notice if a guest user tries to logout" do
      post logout_path

      must_redirect_to root_path
      expect(session[:user_id]).must_equal nil
      expect(flash[:warning]).must_equal "You were not logged in!"
    end
  end
end
