class ItemsController < ApplicationController
  include CartsHelper
  
  
  # TODO: need to refactor, otherwise every new page will create a item in DB, NO GOOD !!!
  def new
    @item = Item.new
    @item.save
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
    render 'new'
  end
  
  def edit
    @item = Item.find(params[:id])
    @size_price, @size_price_str = prepare_size_price(@item)
    render 'new'
  end
  
  def art_filter
    @item = Item.find(params[:id])
    @item.art_filter = false
    @somatic_realtime_api = Rails.configuration.somatic["api_url"]
    @somatic_api_key = Rails.configuration.somatic["api_key"]
    if @item.image.file.nil?
      @filer_image_url = "#{Canvasking::HEROKU_HOST_URL}#{@item.image_tmp_paths['filter']}"
    else
      @filer_image_url = @item.image.filter.url
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
      @item.remove_image!
      @item.save
      @item.update_attribute('art_filter', false)
      @item.remove_art_image!
            
      # Different image source: this will create different versions of tmp images
      if params[:upload_from_facebook]
        @item.remote_image_url = params[:facebook_image_url]
      else
        @item.attributes = item_params
      end
      
      # Override image version url with tmp file path until upload job done
      prepare_tmp_image_paths(@item, 'image_tmp_paths')
      @item.image.crop_version.url = @item.image.crop_version.current_path.split('public')[1]
      
      @crop_image = true
      @size_price, @size_price_str = prepare_size_price(@item)
      render 'new'

    # Image cropped, return to item new page
    elsif params[:image_cropped]
      # Check if image cropped
      if params[:image_cropped_indeed] == "true"
        # Important: Process order should from high to low
        process_now_versions = ['origin','filter', 'cart','overview', 'thumb']
        crop_local_tmp_files(@item, process_now_versions)
      end
      
      # Upload images to S3
      origin_tmp_file_path = "#{Rails.root}/public#{@item.image_tmp_paths['origin']}"
      #ImageUploadWorker.perform_async(origin_tmp_file_path, @item.id, 'image')
      #TmpImageRemoveWorker.perform_in(10.minutes, origin_tmp_file_path, @item.id, 'image')
      @size_price, @size_price_str = prepare_size_price(@item)
      render 'new'

    # Image processed by art filter
    elsif params[:art_filterred]
      # remove old art image if necessary
      @item.remove_art_image!
      @item.save
      @item.update_attribute('art_filter', true)
      @item.attributes = item_params
 
      @item.remote_art_image_url = @item.somatic_url
      prepare_tmp_image_paths(@item, 'art_image_tmp_paths')
      update_tmp_file_names(@item)
      
      # Upload images to S3
      origin_tmp_file_path = "#{Rails.root}/public#{@item.art_image_tmp_paths['origin']}"
      #ImageUploadWorker.perform_async(origin_tmp_file_path, @item.id, 'art_image')
      #TmpImageRemoveWorker.perform_in(10.minutes, origin_tmp_file_path, @item.id, 'art_image')
      
      @size_price, @size_price_str = prepare_size_price(@item)
      render 'new'
                       
    # Item added to cart or edit items in cart
    elsif params[:go_to_cart]
      @item.time_to_save = true
      if @item.update(item_params)
        # Calculate price
        @item.update_attribute(:price, calculate_price(@item.product.name))
        # Add this item to cart
        cart = get_current_cart
        cart.items.push(@item)
        # Update quantity / price
        update_total_price_and_quantity_in_cart
      
        redirect_to cart_path
      else
        # Even it failed, save the correct fields
        @item.attributes = item_params
        @item.save(validate: false)
        @size_price, @size_price_str = prepare_size_price(@item)
        render 'new' # save failed, back to item new page, may caused by missing fields
      end   
      
    # Ajex call for +/- image quantity in cart page
    elsif params[:update_quantity]
      if params[:plus]
        @item.quantity += 1
      elsif params[:minus] && @item.quantity > 1
        @item.quantity -= 1
      end
      @item.save!
      
      # update cart price / quantity
      update_total_price_and_quantity_in_cart
      cart = get_current_cart
      render json: {quantity: @item.quantity, price: cart.price, cart_quantity: cart.quantity}
    end
      
  end
  
  def destroy
    # Update cart quantity
    cart = get_current_cart
    @item = Item.find(params[:id])
    cart.quantity -= @item.quantity
    @item.destroy
    cart.save!
    
    redirect_to cart_path
  end
  
  private
    def prepare_size_price(item)
      size_price_obj = read_size_price_table
      if item.product
        size_price = size_price_obj[item.product.name]
      else
        size_price = {"Please select product first" => ""}
      end
      size_price_str = JSON.dump(size_price_obj)
      return size_price, size_price_str
    end
    
    def read_size_price_table
      YAML.load(File.read(Rails.root.join('business','size_price.yml')))
    end
    
    def calculate_price(product)
      size_price = YAML.load(File.read(Rails.root.join('business','size_price.yml')).gsub!("\\", ""))
      return size_price[product][params[:item][:size]]
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
      crop_x, crop_y, crop_w, crop_h = get_cords_for_origin_version 
      image = MiniMagick::Image.open(origin_file_path)
      image.crop("#{crop_w}x#{crop_h}!+#{crop_x}+#{crop_y}")
      versions.each do |ver|
          abs_path = "#{Rails.root}/public#{item.image_tmp_paths[ver]}"
          width, height = get_resize_width_and_height(ver)
          image.resize("#{width}x#{height}")
          image.write(abs_path)
      end
    end
    
    def get_resize_width_and_height(ver)
      if ver == "cart"
        return 450, 450
      elsif ver == "overview"
        return 300, 300
      elsif ver == "filter"
        return 600, 800
      elsif ver == "thumb"
        return 200, 200
      else
        return 3000, 3000
      end     
    end
    
    def get_cords_for_origin_version
      ratio = Canvasking::IMAGE_VER_ORI/Canvasking::IMAGE_VER_CROP.to_f
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
      end
    end
end
