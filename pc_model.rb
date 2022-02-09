# frozen_string_literal: true

# Required Gems
require 'open-uri'
require 'nokogiri'

# Get PC model from Amazon through ProxyCrawl API
class PcModel
  # Initialize class
  def initialize(url)
    # Interpolate the url with proxycrawl api
    @url = "https://api.proxycrawl.com/scraper?token=#{ENV['PROXYCRAWL_API']}&url=#{url}"
    # Get the response from the API
    pc_serialized = URI.open(@url).read
    # Parse the JSON
    @pc = JSON.parse(pc_serialized)
  end

  def call
    # Returns the Product model number from the JSON
    @pc['body']['productInformation'].find {|x| x['name'] == "Número do modelo"}['value']
  end
end
