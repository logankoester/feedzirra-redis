require 'helper'

class TestFeedzirraRedis < Test::Unit::TestCase
  include FeedzirraRedis

  # Fakeweb reimplemented with symlinks! :-(
  def use_feed(feed)
    real_file = File.join(File.dirname(__FILE__), 'fixtures', "monkeys_#{feed.to_s}.atom")
    symlink   = File.join(File.dirname(__FILE__), 'fixtures', 'monkeys.atom')
    File.delete symlink if File.symlink? symlink
    File.symlink real_file, symlink
    $feed_url = "file://#{symlink}"
  end

  def setup
    Feed.all.destroy
    Entry.all.destroy
    use_feed(:old)
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
      Feed.fetch_and_parse($feed_url)
      assert Feed.count == 1
    end

    should 'return a feed object' do
      feed = Feed.fetch_and_parse($feed_url)
      assert feed.kind_of? Feed
    end

    should 'create some entries' do
      Feed.fetch_and_parse($feed_url)
      assert Feed.first.entries.size >= 0
    end

    should 'not create a second feed if an existing feed has identical feed_url' do
      Feed.fetch_and_parse($feed_url)
      assert Feed.count == 1
      Feed.fetch_and_parse($feed_url)
      assert Feed.count == 1
    end

    should 'add more entries for the same feed url' do
      feed = Feed.fetch_and_parse($feed_url)
      puts feed.entries.last.title
      count_entries = feed.entries.count
      use_feed(:new)
      feed = Feed.fetch_and_parse($feed_url)
      puts feed.entries.last.title
      assert count_entries < feed.entries.count, "Expected increase from #{count_entries} to #{feed.entries.count} (total entries: #{Entry.count})"
    end
  end

  context 'update' do
    should 'update a single feed' do
      feed = Feed.fetch_and_parse($feed_url)
      count_entries = feed.entries.count
      use_feed(:new)
      feed = Feed.update(feed)
      assert count_entries < feed.entries.count, "Expected increase from #{count_entries} to #{feed.entries.count} (total entries: #{Entry.count})"
    end
  end

end
