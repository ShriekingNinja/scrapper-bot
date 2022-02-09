# frozen_string_literal: true

# Required Gems

require 'watir'
require 'webdrivers'
require 'nokogiri'

# Scraper App Class to get original urls and prices from affiliated links
class Scrape
  # REGEX to remove affiliated references
  REGEX = /[^?]+/

  # Initalize Scraper
  def initialize(url)
    # Watir is the headless browser used to mimic a browsing user
    browser = Watir::Browser.new :firefox, options: { args: %w[
      --headless --no-sandbox --disable-dev-shm-usage
      --disable-gpu --remote-debugging-port=9222
    ] }
    # Watir broswer open the input url
    browser.goto url
    # Parse and store the HTML file using Nokogiri
    @doc = Nokogiri::HTML(browser.html)
    # Check if url includes magazine keyword
    if browser.url.include? 'magazine'
      # Scrape the product code from the MagazineLuiza website
      p_code = @doc.css('.product-sku')[0]&.text&.strip
      # Remove non-digits characters from the string
      p_code = p_code.scan(/\d/).join
      # Watir browser open Google search with the magazineluiza product number.
      browser.goto "https://www.google.com/search?q=magazineluiza+#{p_code}/"
      # Parse and store the HTML file using Nokogiri
      mag_search = Nokogiri::HTML(browser.html)
      # Scrape all <a> links from the google page
      original_url = mag_search.css('a')
      # Iterates each <a>
      original_url.each do |l|
        # Convert and store each href of <a> to string
        link = l['href'].to_s
        # Check if link includes/exclude keywords to get the exact original link
        if link.include?('https://www.magazineluiza.com.br/') && link.exclude?('lojas') && link.exclude?('busca') && link.exclude?('google')
          # Store the original link
          @url = link
        end
      end
    else
      # Store the original link without the affiliated references
      @url = browser.url[REGEX]
    end
    # !Close Watir browser
    browser.close
  end

  def call
    # Scrape price for the correct url
    price = case @url
            when /americanas/
              @doc.css('.src__BestPrice-sc-1jvw02c-5')&.text&.strip

            when /magazine/
              @doc.css('.p-price').css('strong')&.text&.strip

            when /amazon/
              @doc.css('.a-offscreen')&.text&.strip

            else
              'Out of stock'
            end
    # If Scrape fails it means the item is out of stock
    price = 'Out of stock' if price.blank?
    # Current date
    date = DateTime.now.new_offset('-03:00')
    # Returns a hash with the url, price and date
    {
      url: @url,
      price: price,
      date: date
    }
  end
end
