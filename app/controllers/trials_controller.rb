class TrialsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    
  end
  
  # Trial Status: initial, active, fail, success
  def create
    # One account for one trial
    if current_user.trials.empty?
      @trial = Trial.new
      @trial.user_id = current_user.id
      @trial.status = "initial"
      @trial.save!  
      
      render 'trial_application_success' 
    else
      render 'trial_application_fail'
    end

    
    
  end
  
  def show
    
  end
end
