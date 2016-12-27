# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


jQuery ->
  new CarrierWaveCropper()

class CarrierWaveCropper
  constructor: ->
    $('#item_image_cropbox').Jcrop
 
      allowSelect: false
      setSelect: [0, 0, 2000, 2000]
      onSelect: @update
      onChange: @update

  update: (coords) =>
    $('#item_image_crop_x').val(coords.x)
    $('#item_image_crop_y').val(coords.y)
    $('#item_image_crop_w').val(coords.w)
    $('#item_image_crop_h').val(coords.h)
    @updatePreview(coords)

  updatePreview: (coords) =>
    $('#item_image_previewbox').css
      width: Math.round(100/coords.w * $('#item_image_cropbox').width()) + 'px'
      height: Math.round(100/coords.h * $('#item_image_cropbox').height()) + 'px'
      marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
      marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'
