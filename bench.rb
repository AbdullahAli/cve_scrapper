require 'hpricot'
require 'net/http'

host = "www.cvedetails.com"
page = "/vulnerability-list.php?page=%s&cvssscoremin=0&cvssscoremax=10"

source = Net::HTTP.get(host, page % 1)
doc = Hpricot(source)
number_of_pages = doc.search("//*[@id='pagingb']/a").last.to_plain_text.to_i

(1..page_number).each do |page_number|
  source = Net::HTTP.get(host, page % page_number)
  doc = Hpricot(source)

  table = doc.search("//*[@id='vulnslisttable']")

  table.search('/tr').each_with_index do |row, index|
    if index.odd?
      row.search('/td').each do |column|
        puts column.to_plain_text
      end
    end
  end
end
