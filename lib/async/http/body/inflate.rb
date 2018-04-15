# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'zlib'

require_relative 'deflate'

module Async
	module HTTP
		module Body
			class Inflate < Deflate
				def self.wrap_response(response)
					if content_encoding = response.headers['content-encoding']
						if encoding = ENCODINGS[content_encoding]
							response.body = self.for(response.body, encoding)
						else
							raise ArgumentError.new("Unsupported content encoding: #{content_encoding.inspect}")
						end
					end
				end
				
				def self.for(body, encoding = GZIP)
					self.new(body, Zlib::Inflate.new(encoding))
				end
				
				def read
					return if @stream.finished?
					
					if chunk = @body.read
						chunk = @stream.inflate(chunk)
					else
						chunk = @stream.finish
					end
					
					return chunk.empty? ? nil : chunk
				end
			end
		end
	end
end