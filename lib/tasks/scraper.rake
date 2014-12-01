namespace :scraper do
  desc "Fetch Craigslist posts from 3taps"
  task scrape: :environment do
  	require 'open-uri'
	require 'json'

	# Set API token and URL
	auth_token = "4da7dae54c72315222db58b7928d6fce"
	polling_url = "http://polling.3taps.com/poll"

	# Specify request parameters
	params = {
		auth_token: auth_token,
		anchor: 1552636426, 
		source: "CRAIG",
		category_group: "RRRR", 
		category: "RHFR", 
		'location.city' => "USA-NYM-BRL",
		retvals: "location,external_url,heading,body,timestamp,price,images,annotations"
	}

	# Prepare API request
	uri = URI.parse(polling_url)
	uri.query = URI.encode_www_form(params)

	#Submit request
	result = JSON.parse(open(uri).read)

	# Display results to screen
	# puts result["postings"].first["location"] ["locality"]
	result["postings"].each do |posting|
	#puts result["postings"].first["annotations"]["bedrooms"]
	#puts JSON.pretty_generate result["postings"].first["annotations"]

	  # Create new Post
	  @post = Post.new
	  @post.heading = posting["heading"]
	  @post.body = posting["body"]
	  @post.price = posting["price"]
	  @post.neighborhood = posting["location"]["locality"]
	  @post.external_url = posting["external_url"]
	  @post.timestamp = posting["timestamp"]
	  @post.bedrooms = posting["annotations"]["bedrooms"] if posting["annotations"]["bedrooms"].present?
	  @post.bathrooms = posting["annotations"]["bathrooms"] if posting["annotations"]["bathrooms"].present?
	  @post.sqft = posting["annotations"]["sqft"] if posting["annotations"]["sqft"].present?
	  @post.cats = posting["annotations"]["cats"] if posting["annotations"]["cats"].present?
	  @post.dogs = posting["annotations"]["dogs"] if posting["annotations"]["dogs"].present?
	  @post.w_d_in_unit = posting["annotations"]["w_d_in_unit"] if posting["annotations"]["w_d_in_unit"].present?
	  @post.street_parking = posting["annotations"]["street_parking"] if posting["annotations"]["street_parking"].present?

	  # Save post
	  @post.save
	end
  end

  desc "Destroy all posting data"
  task destroy_all_posts: :environment do
  	Post.destroy_all
  end

end
