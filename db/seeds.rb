# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Populate Products
product_single_canvas = Product.create(name: "single canvas")
product_triptych_canvas = Product.create(name: "triptych canvas")
product_single_frame = Product.create(name: "frame")

# Populate Frames
#Frame.create(name: "black wood")
#Frame.create(name: "white wood")
#Frame.create(name: "espresso wood")

# # Populate Countrys
# country_us = Country.create(name: "United States")
# country_canada = Country.create(name: "Canada")
# 
# # Populate States
# us_state_list = %w(
# Alabama
# Alaska
# Arizona
# Arkansas
# California
# Colorado
# Connecticut
# Delaware
# Florida
# Georgia
# Hawaii
# Idaho
# Illinois
# Indiana
# Iowa
# Kansas
# Kentucky
# Louisiana
# Maine
# Maryland
# Massachusetts
# Michigan
# Minnesota
# Mississippi
# Missouri
# Montana
# Nebraska
# Nevada
# New\ Hampshire
# New\ Jersey
# New\ Mexico
# New\ York
# North\ Carolina
# North\ Dakota
# Ohio
# Oklahoma
# Oregon
# Pennsylvania
# Rhode\ Island
# South\ Carolina
# South\ Dakota
# Tennessee
# Texas
# Utah
# Vermont
# Virginia
# Washington
# West\ Virginia
# Wisconsin
# Wyoming)
# us_state_list.each do |state|
  # State.create(name: state, country_id: country_us.id)
# end
# 
# canada_province_list = %w(
# Alberta
# British\ Columbia
# Manitoba
# New\ Brunswick
# Newfoundland\ &\ Labrador
# Nova\ Scotia
# Northwest\ Territories
# Nunavut
# Ontario
# Prince\ Edward\ Island
# Quebec
# Saskatchewan
# Yukon
# )
# canada_province_list.each do |province|
  # State.create(name: province, country_id: country_canada.id)
# end