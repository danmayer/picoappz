require 'fog'
require 'erubis'
require './lib/server-files.rb'
include ServerFiles

class PicoAppz

  def initialize
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
  
  APP_DATA = {
    'NothingCalendar' => { 
      'url' => 'http://nothingcalendar.com',
      'image' => 'img/nothing_calendar.png',
      'preview_image' => 'img/nothing_calendar_sm.png',
      'label' => 'NothingCalendar',
      'caption' => 'Track daily progress towards a goal',
    },
    'Blog2Ebook' => {
      'url' => 'http://blog2ebook.picoappz.com/',
      'image' => 'img/blog2ebook.png',
      'preview_image' => 'img/blog2ebook_sm.png',
      'label' => 'Blog2Ebook',
      'caption' => 'Convert RSS feeds to well formatted kindle ebooks.',
    },
    'Churn' => {
      'url' => 'https://github.com/danmayer/churn',
      'image' => 'img/churn.png',
      'preview_image' => 'img/churn_sm.png',
      'label' => 'Churn',
      'caption' => 'Track churn of files, classes, and methods in a project.',
    },
  }

  def copy_public_folder
    puts 'copying'
    `cp -r ./public/ ./tmp`
  end

  def render_templates_to_tmp
    puts 'building'
    Dir["./app/views/**/*.erb"].each do |file|
      puts "processing #{file}"
      template = File.read(file)
      rendered_file = Erubis::Eruby.new(template).result({:title => "picoappz", :data => APP_DATA})
      output_file = file.gsub(/\.erb/,'').gsub(/\/app\/views/,"/tmp")
      File.open(output_file, 'w') {|f| f.write(rendered_file) }
    end
  end

  def upload_to_s3
    puts 'uploading'
    Dir["./tmp/**/*.*"].each do |file|
      unless File.directory?(file)
        mimetype = `file -Ib #{file}`.gsub(/\n/,"")
        mimetype = 'text/css' if file.match(/\.css/)
        filename = file.gsub(/\.\/tmp\//,'')
        puts "uploading #{file} to #{filename}"
        write_file(filename, File.read(file), :content_type => mimetype)
      end
    end
  end

end
