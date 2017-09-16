require 'dotenv/load'
require 'optparse'
require 'twitter'
require 'tempfile'
require_relative './node'
require_relative './node_factory'
require_relative './digraph'

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

root_node = NodeFactory.new.build_node_from_twitter_username(root_username, options)

Digraph.new.generate_image(root_node, options)
