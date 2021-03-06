module Twitter
  class Base
    extend Forwardable

    def_delegators :client, :get, :post, :put, :delete

    attr_reader :client

    def initialize(client)
      @client = client
    end

    # Options: since_id, max_id, count, page
    def home_timeline(query={})
      perform_get("/#{API_VERSION}/statuses/home_timeline.json", :query => query)
    end

    # Options: since_id, max_id, count, page, since
    def friends_timeline(query={})
      perform_get("/#{API_VERSION}/statuses/friends_timeline.json", :query => query)
    end

    # Options: id, user_id, screen_name, since_id, max_id, page, since, count
    def user_timeline(query={})
      perform_get("/#{API_VERSION}/statuses/user_timeline.json", :query => query)
    end

    def status(id)
      perform_get("/#{API_VERSION}/statuses/show/#{id}.json")
    end

    # Options: count
    def retweets(id, query={})
      perform_get("/#{API_VERSION}/statuses/retweets/#{id}.json", :query => query)
    end

    # Options: in_reply_to_status_id
    def update(status, query={})
      perform_post("/#{API_VERSION}/statuses/update.json", :body => {:status => status}.merge(query))
    end

    # DEPRECATED: Use #mentions instead
    #
    # Options: since_id, max_id, since, page
    def replies(query={})
      warn("DEPRECATED: #replies is deprecated by Twitter; use #mentions instead")
      perform_get("/#{API_VERSION}/statuses/replies.json", :query => query)
    end

    # Options: since_id, max_id, count, page
    def mentions(query={})
      perform_get("/#{API_VERSION}/statuses/mentions.json", :query => query)
    end

    # Options: since_id, max_id, count, page
    def retweeted_by_me(query={})
      perform_get("/#{API_VERSION}/statuses/retweeted_by_me.json", :query => query)
    end

    # Options: since_id, max_id, count, page
    def retweeted_to_me(query={})
      perform_get("/#{API_VERSION}/statuses/retweeted_to_me.json", :query => query)
    end

    # Options: since_id, max_id, count, page
    def retweets_of_me(query={})
      perform_get("/#{API_VERSION}/statuses/retweets_of_me.json", :query => query)
    end

    # options: count, page, ids_only
    def retweeters_of(id, options={})
      ids_only = !!(options.delete(:ids_only))
      perform_get("/#{API_VERSION}/statuses/#{id}/retweeted_by#{"/ids" if ids_only}.json", :query => options)
    end

    def status_destroy(id)
      perform_post("/#{API_VERSION}/statuses/destroy/#{id}.json")
    end

    def retweet(id)
      perform_post("/#{API_VERSION}/statuses/retweet/#{id}.json")
    end

    # Options: id, user_id, screen_name, page
    def friends(query={})
      perform_get("/#{API_VERSION}/statuses/friends.json", :query => query)
    end

    # Options: id, user_id, screen_name, page
    def followers(query={})
      perform_get("/#{API_VERSION}/statuses/followers.json", :query => query)
    end

    def user(id, query={})
      perform_get("/#{API_VERSION}/users/show/#{id}.json", :query => query)
    end

    def users(*ids_or_usernames)
      ids, usernames = [], []
      ids_or_usernames.each do |id_or_username|
        if id_or_username.is_a?(Integer)
          ids << id_or_username
        elsif id_or_username.is_a?(String)
          usernames << id_or_username
        end
      end
      query = {}
      query[:user_id] = ids.join(",") unless ids.empty?
      query[:screen_name] = usernames.join(",") unless usernames.empty?
      perform_get("/#{API_VERSION}/users/lookup.json", :query => query)
    end

    # Options: page, per_page
    def user_search(q, query={})
      q = URI.escape(q)
      perform_get("/#{API_VERSION}/users/search.json", :query => ({:q => q}.merge(query)))
    end

    # Options: since, since_id, page
    def direct_messages(query={})
      perform_get("/#{API_VERSION}/direct_messages.json", :query => query)
    end

    # Options: since, since_id, page
    def direct_messages_sent(query={})
      perform_get("/#{API_VERSION}/direct_messages/sent.json", :query => query)
    end

    def direct_message_create(user, text)
      perform_post("/#{API_VERSION}/direct_messages/new.json", :body => {:user => user, :text => text})
    end

    def direct_message_destroy(id)
      perform_post("/#{API_VERSION}/direct_messages/destroy/#{id}.json")
    end

    def friendship_create(id, follow=false)
      body = {}
      body.merge!(:follow => follow) if follow
      perform_post("/#{API_VERSION}/friendships/create/#{id}.json", :body => body)
    end

    def friendship_destroy(id)
      perform_post("/#{API_VERSION}/friendships/destroy/#{id}.json")
    end

    def friendship_exists?(a, b)
      perform_get("/#{API_VERSION}/friendships/exists.json", :query => {:user_a => a, :user_b => b})
    end

    def friendship_show(query)
      perform_get("/#{API_VERSION}/friendships/show.json", :query => query)
    end

    # Options: id, user_id, screen_name
    def friend_ids(query={})
      perform_get("/#{API_VERSION}/friends/ids.json", :query => query)
    end

    # Options: id, user_id, screen_name
    def follower_ids(query={})
      perform_get("/#{API_VERSION}/followers/ids.json", :query => query)
    end

    def verify_credentials
      perform_get("/#{API_VERSION}/account/verify_credentials.json")
    end

    # Device must be sms, im or none
    def update_delivery_device(device)
      perform_post("/#{API_VERSION}/account/update_delivery_device.json", :body => {:device => device})
    end

    # One or more of the following must be present:
    #   profile_background_color, profile_text_color, profile_link_color,
    #   profile_sidebar_fill_color, profile_sidebar_border_color
    def update_profile_colors(colors={})
      perform_post("/#{API_VERSION}/account/update_profile_colors.json", :body => colors)
    end

    # file should respond to #read and #path
    def update_profile_image(file)
      perform_post("/#{API_VERSION}/account/update_profile_image.json", build_multipart_bodies(:image => file))
    end

    # file should respond to #read and #path
    def update_profile_background(file, tile = false)
      perform_post("/#{API_VERSION}/account/update_profile_background_image.json", build_multipart_bodies(:image => file).merge(:tile => tile))
    end

    def rate_limit_status
      perform_get("/#{API_VERSION}/account/rate_limit_status.json")
    end

    # One or more of the following must be present:
    #   name, email, url, location, description
    def update_profile(body={})
      perform_post("/#{API_VERSION}/account/update_profile.json", :body => body)
    end

    # Options: id, page
    def favorites(query={})
      perform_get("/#{API_VERSION}/favorites.json", :query => query)
    end

    def favorite_create(id)
      perform_post("/#{API_VERSION}/favorites/create/#{id}.json")
    end

    def favorite_destroy(id)
      perform_post("/#{API_VERSION}/favorites/destroy/#{id}.json")
    end

    def enable_notifications(id)
      perform_post("/#{API_VERSION}/notifications/follow/#{id}.json")
    end

    def disable_notifications(id)
      perform_post("/#{API_VERSION}/notifications/leave/#{id}.json")
    end

    def block(id)
      perform_post("/#{API_VERSION}/blocks/create/#{id}.json")
    end

    def unblock(id)
      perform_post("/#{API_VERSION}/blocks/destroy/#{id}.json")
    end
    
    # When reporting a user for spam, specify one or more of id, screen_name, or user_id
    def report_spam(options)
      perform_post("/#{API_VERSION}/report_spam.json", :body => options)
    end
    
    def help
      perform_get("/#{API_VERSION}/help/test.json")
    end

    def list_create(list_owner_username, options)
      perform_post("/#{API_VERSION}/#{list_owner_username}/lists.json", :body => {:user => list_owner_username}.merge(options))
    end

    def list_update(list_owner_username, slug, options)
      perform_put("/#{API_VERSION}/#{list_owner_username}/lists/#{slug}.json", :body => options)
    end

    def list_delete(list_owner_username, slug)
      perform_delete("/#{API_VERSION}/#{list_owner_username}/lists/#{slug}.json")
    end

    def lists(list_owner_username = nil, cursor = nil)
      if list_owner_username
        path = "/#{API_VERSION}/#{list_owner_username}/lists.json"
      else
        path = "/#{API_VERSION}/lists.json"
      end
      query = {}
      query[:cursor] = cursor if cursor
      perform_get(path, :query => query)
    end

    def list(list_owner_username, slug)
      perform_get("/#{API_VERSION}/#{list_owner_username}/lists/#{slug}.json")
    end

    # :per_page = max number of statues to get at once
    # :page = which page of tweets you wish to get
    def list_timeline(list_owner_username, slug, query = {})
      perform_get("/#{API_VERSION}/#{list_owner_username}/lists/#{slug}/statuses.json", :query => query)
    end

    def memberships(list_owner_username, query={})
      perform_get("/#{API_VERSION}/#{list_owner_username}/lists/memberships.json", :query => query)
    end

    def list_members(list_owner_username, slug, cursor = nil)
      query = {}
      query[:cursor] = cursor if cursor
      perform_get("/#{API_VERSION}/#{list_owner_username}/#{slug}/members.json", :query => query)
    end

    def list_add_member(list_owner_username, slug, new_id)
      perform_post("/#{API_VERSION}/#{list_owner_username}/#{slug}/members.json", :body => {:id => new_id})
    end

    def list_remove_member(list_owner_username, slug, id)
      perform_delete("/#{API_VERSION}/#{list_owner_username}/#{slug}/members.json", :query => {:id => id})
    end

    def is_list_member?(list_owner_username, slug, id)
      perform_get("/#{API_VERSION}/#{list_owner_username}/#{slug}/members/#{id}.json").error.nil?
    end

    def list_subscribers(list_owner_username, slug)
      perform_get("/#{API_VERSION}/#{list_owner_username}/#{slug}/subscribers.json")
    end

    def list_subscribe(list_owner_username, slug)
      perform_post("/#{API_VERSION}/#{list_owner_username}/#{slug}/subscribers.json")
    end

    def list_unsubscribe(list_owner_username, slug)
      perform_delete("/#{API_VERSION}/#{list_owner_username}/#{slug}/subscribers.json")
    end

    def list_subscriptions(list_owner_username)
      perform_get("/#{API_VERSION}/#{list_owner_username}/lists/subscriptions.json")
    end

    def blocked_ids
      perform_get("/#{API_VERSION}/blocks/blocking/ids.json", :mash => false)
    end

    def blocking(options={})
      perform_get("/#{API_VERSION}/blocks/blocking.json", options)
    end

    protected

    def self.mime_type(file)
      case
        when file =~ /\.jpg/ then 'image/jpg'
        when file =~ /\.gif$/ then 'image/gif'
        when file =~ /\.png$/ then 'image/png'
        else 'application/octet-stream'
      end
    end

    def mime_type(f) self.class.mime_type(f) end

    CRLF = "\r\n"

    def self.build_multipart_bodies(parts)
      boundary = Time.now.to_i.to_s(16)
      body = ""
      parts.each do |key, value|
        esc_key = CGI.escape(key.to_s)
        body << "--#{boundary}#{CRLF}"
        if value.respond_to?(:read)
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(value.path)}\"#{CRLF}"
          body << "Content-Type: #{mime_type(value.path)}#{CRLF*2}"
          body << value.read
        else
          body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF*2}#{value}"
        end
        body << CRLF
      end
      body << "--#{boundary}--#{CRLF*2}"
      {
        :body => body,
        :headers => {"Content-Type" => "multipart/form-data; boundary=#{boundary}"}
      }
    end

    def build_multipart_bodies(parts) self.class.build_multipart_bodies(parts) end

    private

    def perform_get(path, options={})
      Twitter::Request.get(self, path, options)
    end

    def perform_post(path, options={})
      Twitter::Request.post(self, path, options)
    end

    def perform_put(path, options={})
      Twitter::Request.put(self, path, options)
    end

    def perform_delete(path, options={})
      Twitter::Request.delete(self, path, options)
    end

  end
end
