require 'tabula'
require 'pp'

pdf_file = ARGV.first

extractor = Tabula::Extraction::ObjectExtractor.new(pdf_file, 1..2 )
extractor.extract.each do |page|
  page_top = 30 # Ignore page header
  page_left = 0
  page_bottom = page.height-40 # Ignore page footer
  page_right = page.width

  page_area = [page_top, page_left, page_bottom, page_right]
  vertical_rulings = [50,103,198,245,280,370,400,450,542,630,703,727].map{ |n|
    Tabula::Ruling.new(0, n, 0, 1000)
  }

  rows = page.get_area(page_area)
             .get_table(:vertical_rulings => vertical_rulings)
             .rows
             .map {|row|
               # extract text from text elements
               row.map { |te| te.text.gsub(/\s+/, '').strip }
             }
  pp rows.last(2)
end
extractor.close!
