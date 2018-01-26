require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'Base64'

uri = URI.parse('https://deudas.herokuapp.com/accounts')
header = {'Content-Type': 'application/json'}
https = Net::HTTP.new(uri.host,uri.port)
https.use_ssl = true

# POST request & response
req = Net::HTTP::Post.new(uri.path, header)
req.body = {:name => "Hugo", :email => "hugol.soul@gmail.com"}.to_json
res = https.request(req)
res_info = res.body
body_parse = JSON.parse(res_info)

@uuid = body_parse['uuid']
@bills = body_parse['bills']

@amount_decode = Array.new
# decode amount from response array & pushing it on a new Array
@bills.each do |bill|
  bill = Base64.decode64(bill['amount'])
  @amount_decode.push(bill)
end

# due some element have some special character, It's neccesary to remove it
@amount_decode.map!{ |element| element.gsub('$', '') }
# turn the string array into float values
float_array = @amount_decode.map(&:to_f)
# getting the average
@average = float_array.inject{ |sum, el| sum + el }.to_f / float_array.size

# PUT request & response
put_req = Net::HTTP::Put.new(uri.path + "/#{@uuid}", header)
put_req.body = {:average => @average}.to_json
put_res = https.request(put_req)
put_res_info = put_res.body

# if success = {"message":"Thank you for your submission."}
puts put_res_info
