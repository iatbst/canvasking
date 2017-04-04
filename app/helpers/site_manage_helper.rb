module SiteManageHelper
  def calculate_total_payments
    sum = 0
    Order.all.each do |order|
      sum += order.total_price.to_f
    end
    return sum
  end
end
