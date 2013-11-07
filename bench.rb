require 'hpricot'
require 'net/http'
require 'nokogiri'

i1 = Time.now
# puts "==============="
source = Net::HTTP.get("www.cvedetails.com", "/vulnerability-list.php?page=1&cvssscoremin=0&cvssscoremax=10")
doc = Nokogiri::HTML(source)
puts "number of pages: #{doc.search("//*[@id='pagingb']/a[last()]").text.to_i}"
# puts "==============="

number_of_pages = doc.search("//*[@id='pagingb']/a[last()]").text.to_i

(1..3).each do |page_number|
  source = Net::HTTP.get("www.cvedetails.com", "/vulnerability-list.php?page=#{page_number}&cvssscoremin=0&cvssscoremax=10")
  doc = Nokogiri::HTML(source)


  doc = Hpricot(source)
  table = doc.search("//*[@id='vulnslisttable']")

  # puts table.search('/tr/th[2]').text.strip

  table.search('/tr').each do |row|
    # puts row.search('td[2]').text.strip
  end
end
puts "noko #{Time.now-i1}"





i1 = Time.now
# puts "==============="
source = Net::HTTP.get("www.cvedetails.com", "/vulnerability-list.php?page=1&cvssscoremin=0&cvssscoremax=10")
doc = Hpricot(source)
# puts "number of pages: #{doc.search("//*[@id='pagingb']/a").last.to_plain_text.to_i}"
# puts "==============="

number_of_pages = doc.search("//*[@id='pagingb']/a").last.to_plain_text.to_i

(1..3).each do |page_number|
  source = Net::HTTP.get("www.cvedetails.com", "/vulnerability-list.php?page=#{page_number}&cvssscoremin=0&cvssscoremax=10")
  doc = Hpricot(source)


  doc = Hpricot(source)
  table = doc.search("//*[@id='vulnslisttable']")

  # puts table.search('/tr/th[2]').text.strip

  table.search('/tr').each do |row|
    # puts row.search('td[2]').text.strip
  end
end
puts "hpri #{Time.now-i1}"
