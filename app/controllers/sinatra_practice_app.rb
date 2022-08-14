require 'sinatra/base'
require 'ddtrace/auto_instrument'

Datadog.configure do |c|
end


class SinatraPracticeApp < Sinatra::Base
  register Datadog::Tracing::Contrib::Sinatra::Tracer

  get "/" do
      erb :"blogs/new"
  end

  post "/" do
      blog = Blog.new(params["blog"])
      if blog.save
        redirect "/blogs/#{blog.id}"
      else
        erb :"blogs/new"
      end
  end

  get "/blogs/:id" do
      @blog = Blog.find(params[:id])
      erb :"blogs/show"
  end
end