module WordPress
  class Data
    attr_reader :doc, :file_name

    def initialize( file_name )
      file = File.expand_path( "public/xml_backups/#{ file_name }" )
      file = File.open( file )
      @file_name = file_name
      @doc  = Nokogiri::XML( file.read().gsub("\u0004", "") )
    end

    def posts
      @doc.xpath( "//post" ).collect do | post |
        WordPress::Post.new( post, @file_name )
      end
    end
  end

  class Post
    def initialize( doc, file )
      @doc = doc
      @file = file
    end

    def title
      @doc.xpath( "title" ).text
    end

    def slug
      @doc.xpath( "slug" ).text
    end

    def original_date
      Date.parse( @doc.xpath( "Date" ).text ) rescue nil
    end

    def content
      content = @doc.xpath( "content" ).text
      content = format_syntax_highlighter( content )
      content.gsub( /[\n]{2,}+/, "\n\n" )
      images = Nokogiri::HTML( @doc.content ).css( "img" ).collect { | image | image.attributes.values }
      image_links = images.collect { | image_object | image_object[ 1 ].value }.reject { | link | link.empty? || link.nil? }

      image_links.each do | link |
        next if !link.include? "http"

        begin
          file = open( link )
        rescue
          file = open( URI.parse( URI.escape( link ) ) )
        end

        location = "#{ link.split( "/" )[ -1 ] }"
        content[ link ] = process_image_link( file, location )
      end

      content
    end

    def set_featured_img
      default_url = "https://s3.us-east-2.amazonaws.com/beb-backup/logo_default.png"
      links_string = @doc.xpath( "image_url" ).text

      if links_string.empty?
        default_url
      else
        links_arr = links_string.split( "|" )
        featured_image = links_arr[ 0 ]
        file = open( URI.parse( URI.escape( featured_image ) ) )
        location = "#{ featured_image.split( "/" )[ -1 ] }"
        featured_link = process_image_link( file, location )
      end
    end

    def get_img_links( data )
      images = Nokogiri::HTML( data.content ).css( "img" ).collect { | image | image.attributes.values }
      image_links = images.collect { | image_object | image_object[ 1 ].value }.reject { | link | link.empty? || link.nil? }
    end

    def category
      @doc.xpath( "category" ).text.split( "|" )
    end

    def process_image_link( file, location )
      IO.copy_stream( file, location )
      save_image_s3( location )
      FileUtils.rm( location )
      return "https://s3.us-east-2.amazonaws.com/beb-backup/#{ location }"
    end

    def save_image_s3( location )
      file = location
      bucket = 'beb-backup'
      name = File.basename( file )
      obj = AWS_RESOURCE.bucket( bucket ).object( name )
      uploaded_file = obj.upload_file( file )
    end

    def tags
      @doc.xpath( "tags" ).text.split( "|" )
    end

    def format_syntax_highlighter( text )
      text.gsub(/\[(\w+)\](.+?)\[\/\1\]/m) do |match|
        "\n```#{$1}#{$2}```\n"
      end
    end
  end
end
