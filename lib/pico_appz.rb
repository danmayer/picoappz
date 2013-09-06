require 'fog'
require 'erubis'
require 'json'
require 'restclient'
require './lib/server-files.rb'
require './lib/grabzit.rb'
include ServerFiles

class PicoAppz

  def initialize
    @images = nil
    @gh_data = nil
  end

  def build
    copy_public_folder
    render_templates_to_tmp
    upload_to_s3
  end

  def preview
    copy_public_folder
    render_templates_to_tmp
    `open ./tmp/index.html`
  end

  private
  
  def fetch_github_data
    @gh_data ||= begin
                   data_url = 'http://github.fetcher.nathanherald.com/danmayer'
                   response = RestClient.get data_url, :content_type => :json, :accept => :json
                   JSON.parse(response)
                 rescue
                   puts "error fetching GH data"
                   nil
                 end
    @gh_data
  end  

  def app_data
    @app_data = {
      'NothingCalendar' => { 
        'url' => 'http://nothingcalendar.com',
        'label' => 'NothingCalendar',
        'caption' => 'Track daily progress towards a goal',
      },
      'Blog2Ebook' => {
        'url' => 'http://blog2ebook.picoappz.com',
        'label' => 'Blog2Ebook',
        'caption' => 'Convert RSS feeds to well formatted kindle ebooks.',
      },
      'Churn' => {
        'url' => 'http://churn.picoappz.com',
        'label' => 'Churn',
        'caption' => 'Track churn of files, classes, and methods in a project.',
      },
    }
    unless @images
      @images = 'done'
      @app_data.each_pair do |name, data|
        Grabzit.get_image(data['url'], "./tmp/img/#{name}")
        @app_data[name]['image'] = "img/#{name}-full.png"
        @app_data[name]['preview_image'] = "img/#{name}-clipped.png"
      end
    end
  end

  def copy_public_folder
    puts 'copying'
    `cp -r ./public/ ./tmp`
  end

  def render_templates_to_tmp
    puts 'building'
    Dir["./lib/views/**/*.erb"].each do |file|
      puts "processing #{file}"
      template = File.read(file)
      rendered_file = Erubis::Eruby.new(template).result({:title => "picoappz", :data => app_data, :gh_data => fetch_github_data})
      output_file = file.gsub(/\.erb/,'').gsub(/\/lib\/views/,"/tmp")
      File.open(output_file, 'w') {|f| f.write(rendered_file) }
    end
  end

  def upload_to_s3
    puts 'uploading'
    Dir["./tmp/**/*.*"].each do |file|
      unless File.directory?(file)
        mimetype = `file --mime-type -b #{file}`.gsub(/\n/,"")
        mimetype = 'text/css' if file.match(/\.css/)
        filename = file.gsub(/\.\/tmp\//,'')
        puts "uploading #{file} to #{filename}"
        write_file(filename, File.read(file), :content_type => mimetype)
      end
    end
  end

end
