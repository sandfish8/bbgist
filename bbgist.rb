require 'sinatra'

class Array
  def del_in_place(value)
    delete(value)
    self
  end
end

class Bbgist < Sinatra::Base

  SERVER = "http://localhost:4567"
  UPLOAD_DIR = "uploads"

  # show all files
  get '/' do
    entries = Dir.entries(path(UPLOAD_DIR)).del_in_place(".").del_in_place("..")
    entries_with_mtime = get_mtimes(entries)
    entries_with_mtime.sort! { |a,b| b.last <=> a.last }
    entries_with_mtime.map { |e| "#{e.first}\t#{e.last.strftime('%Y-%m-%d %H:%M:%S')}" }.join("\n") + "\n"
  end

  def get_mtimes(entries)
    entries.map do |e|
      [ e, File.mtime(path(UPLOAD_DIR, e)) ]
    end
  end

  # show a file
  get '/:name' do |name|
    return usage if name == "help"
    begin
      File.open(path(UPLOAD_DIR, name), 'r') do |file|
        file.read
      end
    rescue Errno::ENOENT
      "No file #{name}\n"
    end
  end

  # recieve a text upload
  post "/" do

    name = rand_alpha_chars(4)

    File.open(path(UPLOAD_DIR, name), "w") do |f|
      f.write(params[:file][:tempfile].read)
    end

    return "#{SERVER}/#{name}\n"
  end

  def path(dir, name = nil)
   File.join(File.dirname(__FILE__), dir, name.nil? ? "" : name)
  end

  def rand_alpha_chars(num)
    (0...num).map{  65.+(rand(26)).chr}.join
  end

  def usage
    "curl -F file=@FILE_NAME http://#{SERVER}\n"
  end

end
