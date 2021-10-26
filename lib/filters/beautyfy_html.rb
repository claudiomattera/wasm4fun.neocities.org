require 'htmlbeautifier'

class BeautifyHtmlFilter < Nanoc::Filter

  type :text
  identifier :beautify_html

  def run(content, params={})
    HtmlBeautifier.beautify content
  end
end
