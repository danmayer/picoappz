class Grabzit

  #detects osx or linux and runs
  def self.get_image(site_url, image_location)
    `which xvfb-run`
    if !$?.success?
      puts 'image without xvbf'
      `webkit2png #{site_url} -o #{image_location}`
    else
      puts 'image with xvbf'
      `xvfb-run -a -s "-screen 0 1024x768x16" "webkit2png #{site_url} -o #{image_location}"`
    end
  end

end
