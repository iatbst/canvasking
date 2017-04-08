module ApplicationHelper
  
  def generate_title_by_page

    if controller_name == 'welcome'
      return '40% Off Today! Photo Prints On Canvas & Frame With Art-Effects Filters'
    elsif controller_name == 'items'
      return 'Upload Photos & Edit Photos & Order Product | MagicPhotoPrints'
    elsif controller_name == 'carts'
      return 'View & Edit Products In Your Cart | MagicPhotoPrints'
    elsif controller_name == 'pricing'
      return 'Pricing | MagicPhotoPrints'
    elsif controller_name == 'orders'
      if action_name == 'new'
        return 'Check Out & Place Order | MagicPhotoPrints'
      elsif action_name == 'show'
        return 'Order Details | MagicPhotoPrints'
      end
    elsif controller_name == 'custom_registrations'
      if action_name == 'edit'
        return 'Edit Your Profile | MagicPhotoPrints'
      elsif action_name == 'new'
        return 'Join Today, Get 40% Off Discount'      
      end
    elsif controller_name == 'custom_sessions'
      if action_name == 'new'
        return 'Login | MagicPhotoPrints'
      end
    elsif controller_name == 'passwords'
      if action_name == 'new'
        return 'Forget Password | MagicPhotoPrints'
      end
    elsif controller_name == 'user_manage'
      if action_name == 'orders'
        return 'View Open & History Orders | MagicPhotoPrints'
      elsif action_name == 'coupons'
        return 'My Private Coupons | MagicPhotoPrints|'
      end
    elsif controller_name == 'about'
      if action_name == 'privacy_policy'
        return 'Privacy Policy | MagicPhotoPrints'
      elsif action_name == 'terms_of_use'
        return 'Terms of Use | MagicPhotoPrints'
      end
    end
  end
  
  def generate_description_by_page
    if controller_name == 'welcome'
      return 'MagicPhotoPrints provide fantastic Art-Effects photo filters on your photos and 
              produce them into Canvas/Frames/Cups/T-shirts/Iphone-cases...anything you can imagine in real world
              , with great quality and affordable prices.Join us today to get 40% off your first order.
              Shipping is always free !'
    elsif controller_name == 'items'
      return 'Select the photo you want to create from local computer or facebook/instagram social accounts,
             then you could apply Art-Effects filter on photos and select the size & other options for your 
             product. One click to add it to cart.'
    elsif controller_name == 'carts'
      return 'Here are what you have in your cart, you can add new one by continue shopping or check out to place order'
    elsif controller_name == 'pricing'
      return 'Check out our price tables for different kind of product, there is no other extra or hidden charges. Rememebr, shipping is on us!'
    elsif controller_name == 'orders'
      if action_name == 'new'
        return 'Fill in shipping address and credit card to check out. Don\'t forget to fill in coupon code. Our customer always have 35% off discount !'
      elsif action_name == 'show'
        return 'Here is your order details. If any information is incorrect here, please contact us at support@magicphotoprints.com'
      end  
    elsif controller_name == 'custom_registrations'
      if action_name == 'edit'
        return 'You can edit your profile here: choose a nickname or update your password.'
      elsif action_name == 'new'
        return 'Join Us Today to get 40% off discount for your first order.'      
      end
    elsif controller_name == 'custom_sessions'
      if action_name == 'new'
        return 'Login with your MagicPhotoPrints account here. If you forget your password, click the link below
               and we will send you email to reset your password.'
      end
    elsif controller_name == 'passwords'
      if action_name == 'new'
        return 'Fill in your email which you used to sign up. We will send you email to reset your password.'
      end
    elsif controller_name == 'user_manage'
      if action_name == 'orders'
        return 'Here are your open & history orders. Leave us messages about your product.'
      elsif action_name == 'coupons'
        return 'Here are your private coupons. Remember: you can always get 35% off with coupon code MAGICPHOTOPRINTS.'
      end
    elsif controller_name == 'about'
      if action_name == 'privacy_policy'
        return 'Here is our website privacy policy. We Never provide customer informatiomns to other parties and We Never hold your 
               credit card & billing informations.'
      elsif action_name == 'terms_of_use'
        return 'Here is the terms of use with our website. '
      end
    end   
  end
  
  
end
