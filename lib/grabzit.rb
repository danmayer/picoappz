class Grabzit

  def self.get_image(site_url, image_location)
    `webkit2png #{site_url} -o #{image_location}`
  end

end
