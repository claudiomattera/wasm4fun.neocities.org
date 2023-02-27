require 'nokogiri'
require 'image_size'

class GuessImagesSizeFilter < Nanoc::Filter

  type :text
  identifier :guess_images_size

  def run(content, params={})
    # Set assigns so helper function can be used
    @item_rep = assigns[:item_rep] if @item_rep.nil?

    File.open("/root/a.txt", 'w') { |file| file.write(content) }

    add_image_size(content)
  end

  protected

  def add_image_size(content)
    begin
      doc = Nokogiri::HTML5 content
      nodes = doc.xpath('//img')
      nodes.select { |node| node.is_a? Nokogiri::XML::Element }
        .select { |img| img.has_attribute?('src') }
        .each do |img|
          path = img['src']
          width = img['width']
          height = img['height']
          if width && height
          else
            sizes = image_size(path)
            if width && !height
              img['height'] = compute_height(sizes, width)
            elsif !width && height
              img['width'] = compute_width(sizes, height)
            elsif !width && !height
              sizes.each{|k,v| img[k.to_s] = v.to_s}
            end
          end
        end
      result = doc.send("to_html")
    rescue Exception => e
      puts "#{@item.path} Got exception: #{e}"
      result = doc.send("to_html")
    end

    result
  end

  def image_size(path)
    base_path = 'content'
    if path.start_with?('.')
      relative_path = File.join(base_path, @item.path)
      complete_path = File.join(relative_path, path)
    else
      complete_path = File.join(base_path, path)
    end
    image = ImageSize.new(IO.read(complete_path))
    return { :height => image.height, :width => image.width }
  end

  def compute_width(sizes, height)
    sizes[:width].to_i * height.to_i / sizes[:height].to_i
  end

  def compute_height(sizes, width)
    sizes[:height].to_i * width.to_i / sizes[:width].to_i
  end

end
