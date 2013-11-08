require 'redis'
require 'hpricot'
require 'net/http'
require 'csv'


class ApiThrottler
  attr_accessor :redis, :threads

  #need to @redis.flushdb

  GLOBAL = "counter_global"
  MAXIMUM_CALLS_PER_SECOND = 2

  def initialize
    ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
    @@redis = Redis.new
    @@redis.set(GLOBAL, 0)
    @threads = []
  end

  def self.finalize(id)
    @@redis.flushdb
  end

  def local
    "counter_sec_#{Time.now.to_i}"
  end

  def try_fetch(foo)
    if @@redis.get(GLOBAL).to_i <= MAXIMUM_CALLS_PER_SECOND && @@redis.incr(local).to_i <= MAXIMUM_CALLS_PER_SECOND
      perform(foo)
    else
      sleep(1)
      try_fetch(foo)
    end
  end

  def perform(foo)
    @threads << Thread.new(foo) {
      @@redis.incr(GLOBAL)
      foo.call
      @@redis.decr(GLOBAL)
    }
  end
end

class CVEHarvester
  attr_accessor :host, :page, :api_throttler

  def initialize
    @host = "www.cvedetails.com"
    @page = "/vulnerability-list.php?page=%s&cvssscoremin=0&cvssscoremax=10"
    @api_throttler = ApiThrottler.new
  end

  def get_data
    source = Net::HTTP.get(@host, @page % 1)
    doc = Hpricot(source)
    number_of_pages = doc.search("//*[@id='pagingb']/a").last.to_plain_text.to_i

    puts "total pages: #{number_of_pages}"
    (1..number_of_pages).each do |page_number|

      foo = Proc.new {
        source = Net::HTTP.get(@host, @page % page_number)
        doc = Hpricot(source)

        table = doc.search("//*[@id='vulnslisttable']")


        table.search('/tr').each_with_index do |row, index|
          row_data = []
          if index.odd?
            row.search('/td').each do |column|
              row_data << column.search('text()').to_s.strip
              # puts column.search('text()').to_s.strip
            end
            File.open('some-file.txt', 'a') { |f| f.write("#{row_data.to_csv}") }
          end
        end
      }
      api_throttler.try_fetch(foo)
    end
  end

end


i = Time.now
harvester = CVEHarvester.new
harvester.get_data
harvester.api_throttler.threads.each {|t| t.join}
puts "#{Time.now - i}"
