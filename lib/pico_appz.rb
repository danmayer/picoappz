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

  private
  
  def copy_public_folder
    puts 'copying'
    `cp -r ./public/ ./tmp`
  end

  def render_templates_to_tmp
    puts 'building'
    Dir["./app/views/**/*.erb"].each do |file|
      puts "processing #{file}"
      template = File.read(file)
      rendered_file = Erubis::Eruby.new(template).result({:title => "picoappz"})
      output_file = file.gsub(/\.erb/,'').gsub(/\/app\/views/,"/tmp")
      File.open(output_file, 'w') {|f| f.write(rendered_file) }
    end
  end

  def upload_to_s3
    puts 'uploading'
    Dir["./tmp/**/*.*"].each do |file|
      unless File.directory?(file)
        mimetype = `file -Ib #{file}`.gsub(/\n/,"")
        filename = file.gsub(/\.\/public\//,'')
        puts "uploading #{file} to #{filename}"
        write_file(filename, File.read(file), :content_type => mimetype)
      end
    end
  end

end
