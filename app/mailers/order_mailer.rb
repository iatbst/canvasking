class OrderMailer < ApplicationMailer
  
  # Send out email now to user who just placed a order
  def order_confirm(user, order)
    @order = order
    mail(to: user.email, subject: 'Your Order Is completed, Congratulations !!!') 
  end
end
