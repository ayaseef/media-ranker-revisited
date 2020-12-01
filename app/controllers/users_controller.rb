class UsersController < ApplicationController
  skip_before_action :find_user, only: [:create]

  def index
    if @login_user.nil?
      flash[:result_text] = "You must log in to do that"
      return redirect_to root_path
    end
    @users = User.all
  end

  def show
    if @login_user.nil?
      flash[:result_text] = "You must log in to do that"
      return redirect_to root_path
    end
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      # User was found in the database
      flash[:success] = "Successfully logged in as existing user #{user.username}"
    else
      # User doesn't match anything in the DB
      # Attempt to create a new user
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:success] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        # Couldn't save the user for some reason. If we
        # hit this it probably means there's a bug with the
        # way we've configured GitHub. Our strategy will
        # be to display error messages to make future
        # debugging easier.
        flash[:error] = "Could not log in"
        return redirect_to root_path
      end
    end

    # If we get here, we have a valid user instance
    session[:user_id] = user.id
    return redirect_to root_path
  end

  def destroy
    if session[:user_id].nil?
      flash[:warning] = "You were not logged in!"
    else
      session[:user_id] = nil
      flash[:success] = "Successfully logged out!"
    end
    redirect_to root_path
  end
end
