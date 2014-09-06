Bundler.require

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

DataMapper.finalize
DataMapper.auto_upgrade!

helpers do
  include Rack::Utils
  # alias_method :h, :escape_html
end

class App < Sinatra::Base

  enable :method_override

  get '/rss.xml' do
    @notes = Note.all :order => :id.desc
    builder :rss
  end

  get '/' do
    @title = "All Tasks"
    @notes = Note.all({order: :id.desc})

    haml :home
  end

  post '/' do
    Note.new.tap do |n|
      n.content = @params[:content]
      n.created_at = Time.now
      n.updated_at = Time.now
      n.save
    end
    redirect '/'
  end

  get '/:id' do |id|
    @title = "Edit Note"
    @note = Note.get(id)

    haml :edit
  end

  put '/:id' do |id|
    @note = Note.get(id)
    @note.content = params[:note][:content]
    @note.complete = params[:note][:complete] == 'on' ? true : false
    @note.updated_at = Time.now
    @note.save

    redirect '/'
  end

  delete '/:id' do |id|
    @note = Note.get(id)
    if @note
      @note.destroy
    else
      status 404
    end
    redirect '/'
  end

  get '/:id/complete' do |id|
    @note = Note.get(id)
    @note.update({complete: !@note.complete })
    @note.save

    redirect '/'
  end

end
