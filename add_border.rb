#! /usr/local/bin/ruby
# == Synopsis
# Add a double-border to an image, or several images. 
# Requires RMagick
#
# == Usage 
#   ruby add_border.rb files [colour]
#
# == Author 
# Matt Foster <matt.p.foster@gmail.com>
#
# == Copyright
# This file is distributed under the same terms as ruby.

require 'rmagick'
require 'optparse'
require 'rdoc/usage'

outer_colour = 'black'
inner_size   = 8
outer_size   = 200

opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
 
  # I hate this spelling, but for the sake of international compatilibity, I'll
  # put up with it :-)
  opts.on('-c', "--color COLOR", 
               String, 
               "Use COLOR for the outer border") do |col|
    outer_colour = col
  end

  opts.on('-i', "--inner SIZE",
          Integer,
          "Use SIZE as thickness of inner border") do |size|
    inner_size = size
  end

  opts.on('-o', "--outer SIZE",
          Integer,
          "Use SIZE as thickness of outer border") do |size|
    outer_size = size
  end
  
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

opts.parse!

# Remaining args are probably filenames
filenames = ARGV

filenames.each do |filename|
  image = Magick::Image.read(filename).first
  
  # Create a border out of average colour of the image
  samp = image.sample(0.2).statistics
  col = Magick::Pixel.new(samp.red.mean*Magick::MaxRGB,
                          samp.blue.mean*Magick::MaxRGB, 
                          samp.blue.mean*Magick::MaxRGB, 
                          0)

  image.border!(inner_size, inner_size, col)
  image.border!(outer_size, outer_size, outer_colour)

  ext = File.extname(filename)
  base = File.basename(filename, ext)
  dir  = File.dirname(filename)

  image.write(File.join(dir, "#{base}_border#{ext.downcase}"))
end
