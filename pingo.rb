class Pingo < Sinatra::Base
  def initialize(*args)
    super
    @cache = Zache.new
    @client = Thumbtack::Client.new(ENV['PINBOARD_USERNAME'], ENV['PINBOARD_TOKEN'])
    set_last_cleared_time
    populate_cache
  end

  def set_last_cleared_time
    @cache.put(:last_cleared_time, Time.now)
  end

  def populate_cache
    @cache.put(:links, @client.posts.all(tag: 'go'))
  end

  def maybe_reload_cache
    last_updated = @cache.get(:last_updated, lifetime: 30) do
      @client.posts.update.to_time
    end

    return if last_updated < @cache.get(:last_cleared_time)

    logger.info "clearing cache"
    @cache.remove_all
    set_last_cleared_time
    populate_cache
  end

  before do
    if ENV['RACK_ENV'] == 'production'
      expires 5*60, :public, :must_revalidate, :proxy_revalidate
      headers 'Pragma' => 'public'
    end
  end    

  get '/' do
    redirect "https://www.petekeen.net/", 302
  end

  get '/:slug' do
    maybe_reload_cache

    bookmarks = @cache.get(:links).select { |b| b.tags.include?("go:#{params[:slug]}") }

    if bookmarks.length > 0
      redirect bookmarks.sort_by { |b| b.time }.last.href, 302
    else
      redirect "https://www.petekeen.net/#{params[:slug]}", 302
    end
  end
end
