class ItemsController < ApplicationController
  include CartsHelper
  include PricingHelper
  layout "application", except: [:empty_page]

  # TODO: need to refactor, otherwise every new page will create a item in DB, NO GOOD !!!
  def new
    @item = Item.new
    @item.save
    
    @wizard = true
    @new = true
    @show_image_wizard_arrow = true
    @size_price, @size_price_str = prepare_size_price(@item)
  end
  
  # NOT USED, because item is automatically created when user enter new page.
  # All 3 forms (refer update action) are item update actions
  def create
    # This is a photo upload, which create a new item with only image populated
    @item = Item.create(item_params)
    render 'new'     
  end
  
  def show
    @item = Item.find(params[:id])
    @size_price, @size_price_str = prepare_size_price(@item)
    
    # for wizard guide
    @show = true
    
    render 'new'
  end
  
  def edit
    @item = Item.find(params[:id])
    @size_price, @size_price_str = prepare_size_price(@item)
    
    @edit = true
    render 'new'
  end
  
  def art_filter
    @item = Item.find(params[:id])
    @item.art_filter = false
    @somatic_realtime_api = ENV["somatic_api_url"]
    @somatic_api_key = ENV["somatic_api_key"]
    if @item.image.file.nil?
      # Image is not ready on S3
      @filter_image_url = "#{ENV['website_url']}#{@item.image_tmp_paths['filter']}"
    elsif !@item.image_tmp_paths.empty? && @item.image_tmp_paths['origin'].include?('https://')
      # Special Case: this is dup item which cloned from old item, to avoid recreating image,
      # dup image save original image urls to it's image_tmp_paths/art_image_tmp_paths fields
      # This is not a elegant implementation, but save times
      @filter_image_url = @item.image_tmp_paths['filter']
    else
      # Image is ready on S3
      @filter_image_url = @item.image.filter.url
    end
  end
  
  
  # TODO: May need to refactor in future, current logic as follow
  # There are 3 update item forms in new page
  #  - photo upload form ~> new page ( current page )
  #  - crop form ~> new page ( current page )
  #  - Add to cart/Save changes button ~> cart page
  def update
    @item = Item.find(params[:id])
    
    # Image upload to current item, render to crop page
    if params[:image_upload]
      # Remove old image
      clear_old_image_data(@item)
            
      # Different image source: this will create different versions of tmp images
      if params[:upload_from_facebook]
        @item.remote_image_url = params[:facebook_image_url]
      elsif params[:upload_from_instagram]
        @item.remote_image_url = params[:instagram_image_url]
      else
        @item.attributes = item_params
      end
      
      # Override image version url with tmp file path until upload job done
      prepare_tmp_image_paths(@item, 'image_tmp_paths')
 
      @size_price, @size_price_str = prepare_size_price(@item)
      
      render json: {'status'=> 'SUCCESS',
                    'crop_image_url'=> @item.image.cart.current_path.split('public')[1] }

    # Image cropped, return to item new page
    elsif params[:image_cropped]
      params[:item] = JSON.parse(params[:item])
      # Check if image cropped
      if params[:image_cropped_indeed] == "true"
        # Important: Process order should from high to low
        process_now_versions = ['origin','filter', 'overview', 'cart', 'thumb']
        crop_local_tmp_files(@item, process_now_versions)
      end
      
      # get image ratio
      begin
        h_w_ratio = params[:item][:image_crop_h].to_f/params[:item][:image_crop_w].to_f
        @item.update_attribute('image_h_w_ratio', h_w_ratio)
      rescue
      end
              
      # Upload images to S3
      origin_tmp_file_path = "#{Rails.root}/public#{@item.image_tmp_paths['origin']}"
      image_upload_job_id = ImageUploadWorker.perform_async(origin_tmp_file_path, @item.id, 'image')
      image_remove_job_id = TmpImageRemoveWorker.perform_in(Canvasking::IMAGE_TMP_CACHE_TIME.hours, origin_tmp_file_path, @item.id, 'image')
      remove_previous_tmp_file(@item, 'image')
      @item.jobs['image_remove_job_id'] = image_remove_job_id
      @item.update_column('jobs', @item.jobs)
      
      @size_price, @size_price_str = prepare_size_price(@item)
      
      @wizard = true
      @show_filter_wizard_arrow = true
      @update_image_cropped = true
      
      render 'new'

    # Image processed by art filter
    elsif params[:art_filterred]
      
      # Two cases: upload from welcome play around section, or from usual build routine
      # This is the case from welcome page, when normal image S3 store is delayed
      if params[:upload_from_welcome_page]
            h_w_ratio = params[:image_h].to_f/params[:image_w].to_f
            @item.update_attribute('image_h_w_ratio', h_w_ratio)
            
            # In development, new upload images from welcome page are stored on S3 ( local file can't be processed by Somatic API)
            # In Production / Staging, new upload image from welcome page are temp stored on Disk, only upload to S3 when use click button
            # `Order A Canvas On This Style`
            if Rails.env != "development"
              origin_tmp_file_path = "#{Rails.root}/public#{@item.image_tmp_paths['origin']}"
              ImageUploadWorker.perform_async(origin_tmp_file_path, @item.id, 'image')              
            end
      end
      
      # remove old art image if necessary
      @item.update_attribute('art_filter', true)
      @item.attributes = item_params
 
      @item.remote_art_image_url = @item.somatic_url
      prepare_tmp_image_paths(@item, 'art_image_tmp_paths')
      update_tmp_file_names(@item)
      
      # Upload Art images to S3
      origin_tmp_file_path = "#{Rails.root}/public#{@item.art_image_tmp_paths['origin']}"
      art_image_upload_job_id = ImageUploadWorker.perform_async(origin_tmp_file_path, @item.id, 'art_image')
      art_image_remove_job_id = TmpImageRemoveWorker.perform_in(Canvasking::IMAGE_TMP_CACHE_TIME.hours, origin_tmp_file_path, @item.id, 'art_image')
      remove_previous_tmp_file(@item, 'art_image')
      @item.jobs['art_image_remove_job_id'] = art_image_remove_job_id
      @item.update_column('jobs', @item.jobs)
      
      @size_price, @size_price_str = prepare_size_price(@item)
      render 'new'
                       
    # Item added to cart or edit items in cart
    elsif params[:go_to_cart]
      @item.time_to_save = true
      # special process for size, if user failed specify the size option,
      # return error page, not save
      #if params[:item] && params[:item]["size"].nil?
      #  @item.update_attribute("size", nil)
      #end
  
      if @item.update(item_params)
        # Calculate price
        @item.update_attribute(:price, calculate_price(@item))
        # Add this item to cart
        cart = get_current_cart
        cart.items.push(@item)
        # Update quantity / price
        update_total_price_and_quantity_in_cart
        
        if params[:add_to_cart]
          flash[:add_to_cart] = true
        elsif params[:save_changes]
          flash[:save_changes] = true
        end
        
        redirect_to cart_path
      else
        # Even it failed, save the correct fields
        @item.attributes = item_params
        @item.save(validate: false)
        @size_price, @size_price_str = prepare_size_price(@item)
        @save_fail = true
        
        render 'new' # save failed, back to item new page, may caused by missing fields
      end   
      
    # Ajex call for +/- image quantity in cart page
    elsif params[:update_quantity]
      changed = true
      if params[:plus]
        @item.quantity += 1
      elsif params[:minus] && @item.quantity > 1
        @item.quantity -= 1
      else
        changed = false
      end
      @item.save!
      
      # update cart price / quantity
      update_total_price_and_quantity_in_cart
      cart = get_current_cart
      render json: {quantity: @item.quantity, price: cart.price, cart_quantity: cart.quantity, changed: changed}
    end
      
  end
  
  def destroy
    # Update cart quantity
    cart = get_current_cart
    @item = Item.find(params[:id])
    cart.quantity -= @item.quantity
    
    # Remove tmp files if necessary
    remove_previous_tmp_file(@item, 'image')
    remove_previous_tmp_file(@item, 'art_image')
    
    @item.destroy
    cart.save!
    
    flash[:delete_item] = true
    
    redirect_to cart_path
  end
  
  # This is a temp empty page: for instagram images upload purpose
  def empty_page
    
  end
  
  
  
  # Helpers
  private

    
    def calculate_price(item)
      product = item.product.name
      size_price = YAML.load(File.read(Rails.root.join('business','pricing.yml')).gsub!("\\", ""))
      return size_price[product][item.size]
    end
    
    # The x,y,w,z crops coordination passed from Jcrop are based from overview size
    # but carrierwave-jcrop gem crop process them based on origin_size (Not origin image, image after uploaded)
    # need to scale x,y,w,z according
    def scale_crop_cords(origin_size, overview_size)
      params[:item][:image_crop_x] = ((params[:item][:image_crop_x].to_f*(origin_size.to_f/overview_size)).to_i).to_s
      params[:item][:image_crop_y] = ((params[:item][:image_crop_y].to_f*(origin_size.to_f/overview_size)).to_i).to_s
      params[:item][:image_crop_w] = ((params[:item][:image_crop_w].to_f*(origin_size.to_f/overview_size)).to_i).to_s
      params[:item][:image_crop_h] = ((params[:item][:image_crop_h].to_f*(origin_size.to_f/overview_size)).to_i).to_s
    end
    
    def item_params
      if params[:item]
        params.require(:item).permit(:image_crop_x, :image_crop_y, :image_crop_w, \
                                     :image_crop_h, :size, :price, :quantity, :image, \
                                     :depth, :border, :product_id, :art_filter, :somatic_url, \
                                     :frame_id, :mat)
      else
        {}
      end
    end
    
    def image_is_cropped(params, image_width, image_height)
      params[:item][:image_crop_w] != "#{image_width}" || \
      params[:item][:image_crop_h] != "#{image_height}"
    end
   
    
    def prepare_tmp_image_paths(item, col)
      paths = {}
      if col == 'image_tmp_paths'
        paths['origin'] = item.image.current_path.split('public')[1]
        paths['filter'] = item.image.filter.current_path.split('public')[1]
        paths['cart'] = item.image.cart.current_path.split('public')[1]
        paths['overview'] = item.image.overview.current_path.split('public')[1]
        paths['thumb'] = item.image.thumb.current_path.split('public')[1]
      elsif col == 'art_image_tmp_paths'
        paths['origin'] = item.art_image.current_path.split('public')[1]
        paths['filter'] = item.art_image.filter.current_path.split('public')[1]
        paths['cart'] = item.art_image.cart.current_path.split('public')[1]
        paths['overview'] = item.art_image.overview.current_path.split('public')[1]
        paths['thumb'] = item.art_image.thumb.current_path.split('public')[1]     
      end
      item.update_column(col, paths)
    end
    
    def wait_until_upload_job_finished(item)
      counter = 0
      job_id = item.image_tmp
      while counter < 30
        if Sidekiq::Status::complete? job_id
          puts "Job #{job_id} Done"
          break
        end
        counter += 1
        sleep(1)
      end
    end
    
    def crop_local_tmp_files(item, versions)
      origin_file_path = "#{Rails.root}/public#{item.image_tmp_paths['origin']}" 
      image = MiniMagick::Image.open(origin_file_path)
      crop_x, crop_y, crop_w, crop_h = get_cords_for_origin_version(image) 
      image.crop("#{crop_w}x#{crop_h}!+#{crop_x}+#{crop_y}")
      versions.each do |ver|
          abs_path = "#{Rails.root}/public#{item.image_tmp_paths[ver]}"
          width, height = get_resize_width_and_height(ver)
          # No resize for origin version
          if ver != 'origin'
            image.resize("#{width}x#{height}")
          end
          image.write(abs_path)
      end
    end
    
    def get_resize_width_and_height(ver)
      if ver == "cart"
        return 450, 450
      elsif ver == "overview"
        return 500, 500
      elsif ver == "filter"
        return 600, 800
      elsif ver == "thumb"
        return 200, 200
      else
        return 300, 300
      end     
    end
    
    def clear_old_image_data(item)
      # Warn: this function only clear object attribute, DO NOT clear real backend images, which
      # is time consuming !
      item.update_attribute('art_filter', false)
      item.update_attribute('art_image_tmp_paths', {'new_image_uploaded' => true})
    end    
    
    def get_cords_for_origin_version(image)
      if image.width > image.height
        origin_image_dimension = image.width
      else
        origin_image_dimension = image.height
      end 
      ratio = origin_image_dimension/Canvasking::IMAGE_VER_CROP.to_f
      return ((params[:item][:image_crop_x]).to_i*ratio).to_i , \
             ((params[:item][:image_crop_y]).to_i*ratio).to_i , \
             ((params[:item][:image_crop_w]).to_i*ratio).to_i , \
             ((params[:item][:image_crop_h]).to_i*ratio).to_i
    end
    
    # This is a special functions for somatic api, which return image with file extension 'jpg_or_png'
    # Which is silly and need to change
    def update_tmp_file_names(item)
      file_ext = item.art_image_tmp_paths['origin'].split('.')[-1]
      # update all tmp to .jpg and update item.art_image_tmp_paths field
      if file_ext == 'jpg_or_png'
        file_path = "#{Rails.root}/public#{item.art_image_tmp_paths['origin']}"
        folder_path = File.dirname(File.new(file_path))
        Dir.glob("#{folder_path}/*.jpg_or_png").each do |f|
          FileUtils.mv f, "#{File.dirname(f)}/#{File.basename(f,'.*')}.jpg"
        end  
        item.art_image_tmp_paths.each do |ver, path|
          path.gsub!('jpg_or_png', 'jpg')
        end
        item.update_column('art_image_tmp_paths', item.art_image_tmp_paths)
      end
    end
 
     def prepare_size_price(item)
      size_price_obj = read_size_price_table
      
      size_price_obj = process_size_price_table_by_image_ratio(item, size_price_obj)
   
      if item.product
        size_price = size_price_obj[item.product.name]
      else
        size_price = {}
      end
      size_price_str = JSON.dump(size_price_obj)
      return size_price, size_price_str
    end
  
  def available_ratio(ratio, size)
    _size = size.gsub('\\', '')
    _size.gsub!('"', '')
    h = _size.split('x')[0]
    w = _size.split('x')[1]
    h_w_ratio = (h.to_f)/(w.to_f)
    return (1 - ratio.to_f/h_w_ratio).abs < 0.04, h, w, (1 - ratio/h_w_ratio).abs
  end
    
  def process_size_price_table_by_image_ratio(item, size_price_obj)
    
    # get w/h ratio of uploaded image
    if item.image_h_w_ratio
      image_h_w_ratio = item.image_h_w_ratio
    else
      image_h_w_ratio = 1000 # If image failed to load, no price is available
    end
    
    new_size_price_obj = {}
    size_price_obj.each do |product, table|
      
      temp_price_list = []
      table.each do |size, price|
        available_r, h, w, diff = available_ratio(image_h_w_ratio, size)
        # Only reasonable size and none-zero prices
        if available_r && price.to_i != 0
          temp_price_list.push({'h'=> h, 'w'=> w, 's'=> size, 'p'=> price, 'diff'=> diff})
        end
      end
      
      temp_price_list.sort_by! {|obj| obj['diff']}
      temp_price_list = temp_price_list[0..9]
      # TODO: image resolution should be considered, some low resolution can't be print out on large size
      temp_price_list.sort_by! {|obj| [obj['h'].to_i, obj['w'].to_i]}
      
      new_size_price_obj[product] = {}
      temp_price_list.each do |obj|
        new_size_price_obj[product][obj['s']] = obj['p']
      end
       
    end
    
    return new_size_price_obj
  end
  
  # This is a test function to fast make random product/size/price matrix and 
  # populate to /business/pricing.yml
  def _make_price_matrix
    products = ['canvas', 'split canvas', 'framed print']
    
    table_size = 17

    pricing_obj = {}
    base_price = 9.9
    products.each do |product|
      pricing_obj[product] = {}
      h = 8
      w = 8
      base_price += 10
      bump_price = 0
      table_size.times.each do |x|
        table_size.times.each do |y|
          size = "#{h}\\\"x#{w}\\\""
          price = base_price + bump_price
          bump_price += 1
          pricing_obj[product][size] = price
          w += 2
        end
        h += 2
        w = 8
      end
    end
    
    # write to yml
    File.open(Rails.root.join('business','pricing.yml'),"w") do |file|
      file.write pricing_obj.to_yaml
    end 
  end

  # Run the schedule tmp remove job now
  def remove_previous_tmp_file(item, image_type)
    if item.jobs["#{image_type}_remove_job_id"]
      jid = item.jobs["#{image_type}_remove_job_id"]
      ss = Sidekiq::ScheduledSet::new
      job = ss.select {|j| j.jid == jid }
      job = job[0]
      if job && job.reschedule(Time.now)
        puts "Job #{jid} Re-schedule SUCCESS !"
      else
        puts "Job #{jid} Re-schedule FAIL !"
      end
    end
  end
end
