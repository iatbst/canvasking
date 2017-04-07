module ApplicationHelper
  
  def generate_title_by_page

    if controller_name == 'welcome'
      return 'Canvas Prints - Canvas Photo Prints | Prisma Style Filters'
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
        return 'Sign Up | MagicPhotoPrints'      
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
end
