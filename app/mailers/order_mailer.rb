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

  # Send out email to site admin
  def order_notify(user, order)
    @order = order
    user_email = user ? user.email : order.guest_email
    admin_email = Canvasking::ADMIN_EMAIL
    mail(to: admin_email, subject: "Congratulations ! New Order (#{order.number}) is coming from #{user_email}.") 
  end
end
