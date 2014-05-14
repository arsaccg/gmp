


# require 'thread'

# queue = Queue.new

# producer = Thread.new do
#   5.times do |i|
#     sleep rand(i) # simulate expense
#     queue << i
#     puts "#{i} produced"
#   end
# end

# consumer = Thread.new do
#   5.times do |i|
#     value = queue.pop
#     sleep rand(i/2) # simulate expense
#     puts "consumed #{value}"
#   end
# end

# producer.join





require 'thread'

count = 0
arr = []
seconds = Time.now

arr_text = ""
queue_count = 0
queue = SizedQueue.new(4)

3.times do |i|
   arr[i] = Thread.new {

   	queue << count
      queue_count = queue_count + 1
      Thread.current["mycount"] = count
      count += 1
 
		

      arr_text = arr_text +  " " + count.to_s
      p queue 
     
       
   }
    #arr[i].join
end

arr.each {|t| t.join }

timesec = Time.now - seconds
puts "result " + timesec.to_s
#puts "result " + arr_text

