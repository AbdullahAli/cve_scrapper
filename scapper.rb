require 'open-uri'
require 'nokogiri'

# Perform a google search
doc = Nokogiri::HTML(open('http://www.cvedetails.com/cve/CVE-2011-5165'))
# puts doc.inspect
# puts doc.search("//table[@id='vulnslisttable']").count

table = doc.search(%Q(//*[@id="vulnrefstable"]))


# tr[2]/td
# # Print out each link using a CSS selector
table.css('tr > td').each do |td|
  puts "========="
  puts td
  puts "========="
end
