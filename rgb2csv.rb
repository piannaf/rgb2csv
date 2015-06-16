require 'tabula'
require 'pp'

def extract_data_from(pdf_file)
  extractor = Tabula::Extraction::ObjectExtractor.new(pdf_file, 1..2 )
  tables = extractor.extract.map { |page|
    table_area = select_table_area_from(page)
    table = extract_table_from(table_area)
    cleanup(table)
  }
  extractor.close!

  combine(tables)
end

def select_table_area_from(page)
  table_top = 30 # Ignore page header
  table_left = 0
  table_bottom = page.height-40 # Ignore page footer
  table_right = page.width

  table_area = [table_top, table_left, table_bottom, table_right]
  page.get_area(table_area)
end

def extract_table_from(table_area)
  vertical_rulings = [50,103,198,245,280,370,400,450,542,630,703,727].map{ |n|
    Tabula::Ruling.new(0, n, 0, 1000)
  }

  table_area.get_table(:vertical_rulings => vertical_rulings)
end

def cleanup(table)
  table.rows.map {|row|
    # extract text from text elements
    # and remove some strange whitespace
    row.map { |te| te.text.gsub(/\s+/, '').strip }
  }
end

def combine(tables)
  # All tables have the same header
  # Ensure it stays a line of its own so we can concat to the rest
  header = [tables[0][0]]

  body = tables.map { |table| table[1..-1] }.flatten(1)

  header.concat(body)
end

def csv_from(data)
  data.map { |line| line.join(",") }.join("\n") + "\n"
end

pdf_file = ARGV.first
data = extract_data_from(pdf_file)
print csv_from(data)
