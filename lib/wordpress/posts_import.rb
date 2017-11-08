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
      @doc.xpath( "//item[wp:post_type = 'post']" ).collect do | post |
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
      @doc.xpath( "wp:post_name" ).text
    end

    def original_date
      Date.parse( @doc.xpath( "pubDate" ).text )
    end

    def content
      content = @doc.xpath( "content:encoded" ).text
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
        IO.copy_stream( file, location )
        save_image_s3( location )
        uploaded_link = "https://s3.us-east-2.amazonaws.com/beb-backup/#{ location }"
        FileUtils.rm( location )
        content[ link ] = uploaded_link
      end

      content
    end

    def comments
      @doc.xpath( "wp:comment" ).collect do | comment |
        Comment.new( body: comment.text )
      end
    end

    def set_featured_img
      default_url = "https://s3.us-east-2.amazonaws.com/beb-backup/logo_default.png"
      image_links = get_img_links( @doc )
      correct_links = image_links.collect { | link | link if link.include? "http" }.compact

      if correct_links.empty?
        default_url
      else
        location = "#{ correct_links[ 0 ].split( "/" )[ -1 ] }"
        uploaded_link = "https://s3.us-east-2.amazonaws.com/beb-backup/#{ location }"
        uploaded_link
      end
    end

    def get_img_links( data )
      images = Nokogiri::HTML( data.content ).css( "img" ).collect { | image | image.attributes.values }
      image_links = images.collect { | image_object | image_object[ 1 ].value }.reject { | link | link.empty? || link.nil? }
    end

    def category
      @file.gsub( "_", " " ).split( "." )[ 0 ].split( " " ).map( &:capitalize ).join( " " )
    end

    def save_image_s3( location )
      file = location
      bucket = 'beb-backup'
      name = File.basename( file )
      obj = AWS_RESOURCE.bucket( bucket ).object( name )
      uploaded_file = obj.upload_file( file )
    end

    def format_syntax_highlighter( text )
      text.gsub(/\[(\w+)\](.+?)\[\/\1\]/m) do |match|
        "\n```#{$1}#{$2}```\n"
      end
    end
  end
end
