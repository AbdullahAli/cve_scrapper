require 'atomic'

class Script

  COUNTER_CAP = 50

  @@urls = *(1..100)
  @@counter = Atomic.new(0)

  def start_up
    @@urls.each do |url|
      try_fetch_url(url)
    end
  end

  def try_fetch_url(url)
    if @@counter.value < COUNTER_CAP
      increment_counter
      spawn_thread(url)
    else
      sleep(1)
      try_fetch_url(url)
    end
  end

  def spawn_thread(url)
    Thread.new do
      perform_job(url)
      decrement_counter
    end
  end

  def perform_job(url)
    File.open('some-file.txt', 'a') { |f| f.write("#{url} \n") }
  end

  def increment_counter
    @@counter.try_update {|v| v + 1}
  end


  def decrement_counter
    @@counter.try_update {|v| v - 1}
  end
end

script = Script.new
script.start_up
