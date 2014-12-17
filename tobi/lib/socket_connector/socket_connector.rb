
require 'socket'

module SOCKET_CONNECTOR

	def ask_socket(query)

		arr_resp = Array.new

		s = TCPSocket.new '10.10.10.20', 8090
		 
		s.send("query",0)
		s.send(query,0)
		a=s.recv(2048)
		a=s.recv(2048)
		while !(a.to_s.include? "EOF")
			
			a=s.recv(2048)
			if !(a.to_s.include? "EOF")
				arr_resp << a
			end
			p a
		end

		s.send("quit",0)

		s.close   
		return arr_resp          # close socket when done
	end
end


    