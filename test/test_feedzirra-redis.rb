require 'helper'

class TestFeedzirraRedis < Test::Unit::TestCase
  include FeedzirraRedis

  def setup
    Feed.all.destroy
    Entry.all.destroy
  end

  context 'A feed' do

    should 'can be saved with no arguments' do
      redis_feed = Feed.new
      redis_feed.save
      assert Feed.count == 1
    end
  end

  context 'fetch_and_parse' do
    should 'create a feed' do
      Feed.fetch_and_parse(FEED_URL)
      assert Feed.count == 1
    end

    should 'return a feed object' do
      feed = Feed.fetch_and_parse(FEED_URL)
      assert feed.kind_of? Feed
    end

    should 'create some entries' do
      Feed.fetch_and_parse(FEED_URL)
      assert Feed.first.entries.size >= 0
    end

    should 'not create a second feed if an existing feed has identical feed_url' do
      Feed.fetch_and_parse(FEED_URL)
      assert Feed.count == 1
      Feed.fetch_and_parse(FEED_URL)
      assert Feed.count == 1
    end

    should 'add more entries for the same feed url' do
      feed = Feed.fetch_and_parse(FEED_URL)
      count_entries = feed.entries.count
      FakeWeb.register_uri( :get, FEED_URL,
                            :body => File.read('test/fixtures/monkeys_new.atom') )
      Feed.fetch_and_parse(FEED_URL)
      assert count_entries < Feed.entries.count
    end
  end

end
