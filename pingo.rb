class Pingo < Sinatra::Base
  def initialize(*args)
    super
    @cache = Zache.new
    @client = Thumbtack::Client.new(ENV['PINBOARD_USERNAME'], ENV['PINBOARD_TOKEN'])
    set_last_cleared_time
  end

  def set_last_cleared_time
    @cache.put(:last_cleared_time, Time.now)
  end

  def maybe_clear_cache
    last_updated = @cache.get(:last_updated, lifetime: 30) do
      @client.posts.update.to_time
    end

    return if last_updated < @cache.get(:last_cleared_time)

    logger.info "clearing cache"
    @cache.remove_all
    set_last_cleared_time
  end

  get '/' do
    "pingo"
  end

  get '/:slug' do
    maybe_clear_cache

    bookmarks = @cache.get('link:' + params[:slug]) do
      @client.posts.get(tag: ['go', 'go:' + params[:slug]])
    end

    if bookmarks.length > 0
      redirect bookmarks.sort_by { |b| b.time }.last.href, 302
    else
      redirect "https://www.petekeen.net/#{params[:slug]}"
    end
  end
end
