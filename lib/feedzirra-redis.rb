%w{rubygems feedzirra dm-core dm-redis-adapter}.each { |f| require f }

module FeedzirraRedis

  class Entry
    include DataMapper::Resource
    property :id,           Serial
    property :guid,         String, :index => true
    property :title,        String
    property :url,          String
    property :author,       String
    property :summary,      Text
    property :content,      Text
    property :published,    Time

    belongs_to :feed
  end

  class Feed
    include DataMapper::Resource
    property :id,            Serial
    property :title,         String
    property :url,           String
    property :feed_url,      String, :index => true
    property :etag,          String
    property :last_modified, DateTime

    has n, :entries

    def add_entries(entries)
      entries.each do |entry|
        Entry.first_or_create( {:guid => entry.guid}, {
          :title        => entry.title,
          :summary      => entry.summary,
          :url          => entry.url,
          :published    => entry.published,
          :feed         => self
        })
      end
    end

    def self.fetch_and_parse(urls, options = {})
      if urls.is_a?(String)
        feed = Feedzirra::Feed.fetch_and_parse(urls, options)
        update_redis_from feed
      else
        feeds = Feedzirra::Feed.fetch_and_parse(urls, options)
        redis_feeds = {}
        feeds.map do |feed|
          redis_feed = update_redis_from feed
          redis_feeds.merge!(redis_feed.feed_url => redis_feed)
        end
      end
    end

    # Delegate for compatibility
    def self.update(feeds, options = {})
      self.fetch_and_parse(feeds, options)
    end

  private
    def self.update_redis_from(feed)
      redis_feed = Feed.first_or_create(:feed_url => feed.feed_url)
      redis_feed.update({
        :title         => feed.title,
        :url           => feed.url,
        :etag          => feed.etag,
        :last_modified => feed.last_modified
      })
      feed.entries.each do |feed_entry|
        redis_feed.entries.first_or_create({ :id => feed_entry.id }, {
        })

      end
      return redis_feed
    end
  end

end
