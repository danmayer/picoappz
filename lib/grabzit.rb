require 'grabzit'

class Grabzit

  def self.get_image(site_url, image_location)
    `webkit2png #{site_url} -o #{image_location}`
    #pdf_file = image_location.gsub('.jpg','.pdf')
    #cmd = "wkhtmltopdf 'www.google.com' #{pdf_file}"
    #puts cmd
    #`#{cmd}`
    #`convert -crop 100x100+0+100 #{pdf_file} #{image_location}`
    #grabzItClient = GrabzIt::Client.new(ENV['GRABIZT_KEY'], ENV['GRABIZT_SECRET'])
    #grabzItClient.save_picture("http://www.google.com", image_location)
  end
  
end
