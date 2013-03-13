require 'sinatra'
require 'netaddr'
require 'cgi'
require_relative 'lib/array'

class Bbgist < Sinatra::Base

  SERVER = "https://bbgist.blueboxgrid.com"
  UPLOAD_DIR = "uploads"
  ID_LENGTH = 10


  # referenced from https://thevault.blueboxgrid.com/index.php/IP_Space_Allocation
  TRUSTED_NETWORKS = ["208.85.144.0/21",
                      "67.214.208.0/20",
                      "199.91.168.0/22",
                      "199.182.120.0/22"]

  USERNAME = "bbgist"
  PASSWORD = "rumor1:newts"

  # show all files
  get '/' do
    authorized do
      @entries = ordered_entries
      erb :index
    end
  end

  get '/login' do
    @login_failed = params.key?("login_failed")
    erb :login
  end

  get '/logout' do
    response.delete_cookie('authorized')
    redirect '/'
  end

  post '/login' do
    request.body.rewind
    data = CGI.parse(request.body.read)
    username = data["username"].first
    password = data["password"].first

    if username != USERNAME || password != PASSWORD
      redirect '/login?login_failed', 303 # see comment below
    else
      response.set_cookie('authorized', :value => true, :expires => Time.now + 3600*24*365*10 ) # expires in 10 years
      redirect '/', 303 # http://www.gittr.com/index.php/archive/details-of-sinatras-redirect-helper/
    end
  end

  # show a file
  get '/get' do
    authorized do
    content_type :text
      name = params[:name]
      name = get_first_entry if name == "first"
      begin
        File.open(path(UPLOAD_DIR, name), 'r') do |file|
          file.read
        end
      rescue Errno::ENOENT
        "No file #{name}\n"
      end
    end
  end

  # download a file
  get '/dl' do
    authorized do
      name = params[:name]
      name = get_first_entry if name == "first"
      begin
        send_file path(UPLOAD_DIR, name), :filename => name, :type => 'Application/octet-stream'
      rescue Errno::ENOENT
        "No file #{name}\n"
      end
    end
  end

  # add or remove a file
  post "/" do
    authorized do
      if params[:_method] == "delete"
        name = params[:name]
        FileUtils.rm(path(UPLOAD_DIR, name))
        "#{name} removed."
      else
        if params[:file]
          name = rand_alpha_chars(ID_LENGTH)
          File.open(path(UPLOAD_DIR, name), "w") do |f|
            f.write(params[:file][:tempfile].read)
          end
          "#{SERVER}/get?name=#{name}\n"
        else
          "Error: no file to upload"
        end
      end
    end
  end

  # delete a file
  delete "/:name" do |name|
    FileUtils.rm(path(UPLOAD_DIR, name))
    redirect "/"
  end

  # recieve a text upload
  post "/web_upload" do
    authorized do
      name = rand_alpha_chars(ID_LENGTH)
      if params[:file]
        tempfile = params[:file][:tempfile]
        FileUtils.cp(tempfile.path, path(UPLOAD_DIR, name))
      end
      redirect '/'
    end
  end

  get '/help' do
    usage
  end

  get '/first' do
    redirect '/get?name=first'
  end

  def authorized(&block)
    if not_authorized?
      redirect '/login'
    else
      block.call
    end
  end

  def not_authorized?
    !request.cookies.key?("authorized") && !trusted_ip?
  end

  def trusted_ip?
    TRUSTED_NETWORKS.each do |n|
      if NetAddr::CIDR.create(n).contains?(request.ip)
        return true
      end
    end
    false
  end

  def ordered_entries
    entries = Dir.entries(path(UPLOAD_DIR)).del_in_place(".").del_in_place("..")
    entries_with_mtime = get_mtimes(entries)
    entries_with_mtime.sort! { |a,b| b[:mtime] <=> a[:mtime] }
  end

  def get_first_entry
    ordered_entries.first[:name]
  end

  def get_mtimes(entries)
    entries.map do |e|
      { :name => e,
        :mtime => File.mtime(path(UPLOAD_DIR, e)),
        :size => File.size(path(UPLOAD_DIR, e))
      }
    end
  end

  def path(dir, name = nil)
   File.join(File.dirname(__FILE__), dir, name.nil? ? "" : name)
  end

  def rand_alpha_chars(num)
    (0...num).map{  97.+(rand(26)).chr}.join
  end

  def usage
    "curl -k -F file=@FILE_NAME #{SERVER}\n"
  end

end
