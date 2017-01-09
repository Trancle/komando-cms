module LiquidFilter
  module ResizeImg

    def resize_img( image_hash, extension, width, height = nil )
      return 'Liquid Error: image_hash, extension, and width are all required for resize_img' if image_hash.nil? or extension.nil? or width.nil?
      raise "image_hash was nil" if image_hash.nil?

      resized_image_base_path = ResizedImagesCachePathPhysical.pathname
      size_id = width.to_s
      resized_phys_path = resized_image_base_path.join( LiquidFilter::ResizeImg.hash_string_to_path( image_hash ).to_s ).to_s + '-' + size_id + '.' + extension
      resized_virt_path = ResizedImagesCachePathVirtual.pathname.join( LiquidFilter::ResizeImg.hash_string_to_path( image_hash ).to_s ).to_s + '-' + size_id + '.' + extension

      unless File.exist?(resized_phys_path)
        # produce the file:
        public_image = PublicImage.find_by_file_hash( image_hash )

        return resized_virt_path unless File.readable?(public_image.local_path)

        img = Magick::Image.read(public_image.local_path) do
          self.format = public_image.file_extension.upcase
        end
        img = img.first

        # resize the image
        if height.nil?
          img.resize_to_fit!( width )
        else
          img.resize!( width, height )
        end
        begin
          # Create the folders required to place the resized file
          FileUtils.mkdir_p File.dirname(resized_phys_path)
          # write out the resized image to the resized path
          img.write( resized_phys_path )
        rescue StandardError => e
          logger.error "Image File: '#{resized_phys_path}' unable to be written (do we have write permission?)"
          # gracefully fallback. File will 404.
          return resized_virt_path
        end

        image_optim = ImageOptim.new( :pngout => false )
        # optimize the resized image
        image_optim.optimize_image!( resized_phys_path )
      end

      # return the relative, virtual path of the resized and optimized file:
      resized_virt_path
    end


    def hash_string_to_path( h )
      self.class.hash_string_to_path(h)
    end

    def self.hash_string_to_path( h )
      raise "Hash was nil but cannot be" if h.nil?
      raise "Hash was blank" if h.empty?
      raise "Hash: '#{h}' is too short" if h.size < 32
      Pathname.new(h[0..2]).join(h[3..5]).join(h[6..-1])
    end
  end
end
Liquid::Template.register_filter(LiquidFilter::ResizeImg)