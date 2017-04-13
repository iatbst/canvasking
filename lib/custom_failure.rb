  class CustomFailure < Devise::FailureApp

    # You need to override respond to eliminate recall
    def respond
      if params[:guest_check_out]
        flash[:guest_check_out] = true
      end
      
      if http_auth?
        http_auth
      else
        redirect
      end
    end
  end