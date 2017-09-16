# Twitter follower graph

This is a small sample to create a graph of your twitter followers and to show how your network explodes

You will need to [register your application on Twitter](https://apps.twitter.com/) before using this.

Also you will need to set the appropriate values to the environment variables

``` shell
TWITTER_CONSUMER_KEY
TWITTER_CONSUMER_SECRET
```

Then you can draw the graph with

``` shell
ruby lib/following_graph.rb rafadc
```

This will create a graph that shows who the user [rafadc](https://twitter.com/rafadc) is following and the people that its followers follow.

The output file will be placed in the *output* folder
