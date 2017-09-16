require 'dotenv/load'
require 'optparse'
require 'twitter'
require 'pry'

raise 'You need to set env variables. Check README.' unless ENV['TWITTER_CONSUMER_KEY'] && ENV['TWITTER_CONSUMER_SECRET']

options = {
  depth: 2,
  width: 10,
  output: 'output/graph.png',
  verbose: false
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby lib/following_graph.rb [options] [user]'

  opts.on('-d', '--depth DEPTH', Integer, "How deep to go into the graph. Defaults to #{options[:depth]}.") do |v|
    options[:depth] = v
  end

  opts.on('-w', '--width WIDTH', Integer, "How much people per level. Defaults to #{options[:width]}.") do |v|
    options[:width] = v
  end

  opts.on('-o', '--ouptut OUTPUT', "Output file. Defaults to #{options[:output]}.") do |v|
    options[:output] = v
  end

  opts.on('-v', '--verbose', 'Verbose mode.') do |v|
    options[:verbose] = true
  end
end.parse!

root_username = ARGV.last

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
end

root_node = build_node_from_twitter_username(client, root_username, options, options[:depth])

temp_file = Tempfile.new(['twitter_grahviz_file', '.dot'])
temp_file.write(graph_string(root_node))
temp_file.flush

command = "dot #{temp_file.path} -o #{options[:output]} -Kdot -Tpng"
puts "Invoking: #{command}"
system command

BEGIN {
  Node = Struct.new(:name, :relations)

  def graph_string(root_node)
    output = "digraph G {\n"
    output << "\t ratio=.3;\n"
    output << draw_node(root_node)
    output << "}\n"
    output
  end

  def draw_node(node)
    output = "\t#{node.name};\n"
    node.relations.each do |child|
      output << "\t#{node.name} -> #{child.name};\n"
      output << draw_node(child)
    end
    output
  end

  def build_node_from_twitter_username(client, username, options, remaining_depth)
    node = Node.new(username)
    if remaining_depth > 0
      following = retrieve_user_friends(client, username, options)
      node.relations = following.map { |followed| build_node_from_twitter_username(client, followed.screen_name, options, remaining_depth - 1) }
    else
      node.relations = []
    end
    node
  end

  def retrieve_user_friends(client, username, options)
    client.friends(username).take(options[:width])
  rescue Twitter::Error::TooManyRequests => error
    wait = error.rate_limit.reset_in + 10
    puts "Waiting #{wait} seconds due to rate limit reached" if options[:verbose]
    sleep wait
    retry
  end
}
