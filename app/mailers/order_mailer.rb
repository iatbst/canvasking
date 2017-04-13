class OrderMailer < ApplicationMailer
  # require application helpers
  add_template_helper(ItemsHelper)
  
  # Send out email now to user who just placed a order
  def order_confirm(user, order)
    @order = order
    @user = user
    email = user ? user.email : order.guest_email
    mail(to: email, subject: 'Your Order Is Completed, Congratulations !') 
  end
end
