require 'tabula'

pdf_file = ARGV.first

extractor = Tabula::Extraction::ObjectExtractor.new(pdf_file, 1..2 )
extractor.extract.each do |page|
  page_top = 0;
  page_left = 0;
  page_bottom = page.height
  page_right = page.width

  page_area = [page_top, page_left, page_bottom, page_right]
  vertical_rulings = [50,103,198,245,280,370,400,450,542,630,703,727].map{ |n|
    Tabula::Ruling.new(0, n, 0, 1000)
  }

  print page.get_area(page_area)
            .get_table(:vertical_rulings => vertical_rulings)
            .to_csv
end
extractor.close!
