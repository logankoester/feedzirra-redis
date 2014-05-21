# feedzirra-redis

> Since `v1.0.0`, [feedjira](https://github.com/feedjira/feedjira) replaces feedzirra. All future development has moved to [feedjira-redis](https://github.com/logankoester/feedjira-redis). Please update your projects accordingly.

FeedzirraRedis uses Datamapper's dm-redis-adapter to provide a persistance layer for the [Feedzirra](https://github.com/pauldix/feedzirra) RSS/Atom feed consumption library.

## Example Usage

FeedzirraRedis can be used in much the same fashion as [Feedzirra](https://github.com/pauldix/feedzirra) itself. One common use for FeedzirraRedis is to avoid updating the feed with every page hit, so you could update the feed from a Rakefile on a cron job instead.

#### Shared

    DataMapper.setup(:default, { :adapter  => 'redis' })
    FEED_URL = 'https://github.com/logankoester/feedzirra-redis/commits/master.atom'

#### Rakefile

    namespace :blog do
      desc 'Grab the latest blog posts'
      task :update do
        FeedzirraRedis::Feed.fetch_and_parse(FEED_URL)
      end
    end

FeedzirraRedis::Feed is actually a Datamapper model that wraps the interface to Feedzirra::Feed with some code to add persistence. Feeds are uniquely identified by their `feed_url` property, so when you call `fetch_and_parse` or `update` a second time the new entries are associated with the original feed.

Run `rake blog:update` to grab some entries.

#### Action
Now you just need to fetch the object your Rakefile created.

`@feed = FeedzirraRedis::Feed.first(:feed_url => FEED_URL)`

#### View
FeedzirraRedis::Entry is also a Datamapper model, but it shares the same properties as Feedzirra::Entry.

    %h1= @feed.title
      - @feed.entries.each do |e|
        %h2= e.title
        %p= e.content

See the [Feedzirra](https://github.com/pauldix/feedzirra) documentation or [read the code](https://github.com/logankoester/feedzirra-redis/blob/master/lib/feedzirra-redis.rb) (it's short!) for further details.

## Contributing to feedzirra-redis
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011-2014 Logan Koester. See LICENSE.txt for
further details.
