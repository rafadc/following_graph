# Builds a node for a graph from a Twitter username
class NodeFactory
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    end
  end

  def build_node_from_twitter_username(username, options, remaining_depth = options[:depth])
    node = Node.new(username)
    if remaining_depth > 0
      following = retrieve_user_friends(username, options)
      node.relations = following.map { |followed| build_node_from_twitter_username(followed.screen_name, options, remaining_depth - 1) }
    else
      node.relations = []
    end
    node
  end

  private

  def retrieve_user_friends(username, options)
    @client.friends(username).take(options[:width])
  rescue Twitter::Error::TooManyRequests => error
    wait = error.rate_limit.reset_in + 10
    puts "Waiting #{wait} seconds due to rate limit reached" if options[:verbose]
    sleep wait
    retry
  end
end
