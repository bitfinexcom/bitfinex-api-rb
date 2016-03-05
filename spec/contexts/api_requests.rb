RSpec.shared_context "api requests" do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:client) { Bitfinex::Client.new }

  def stub_http(path, body, method: :get, status: 200)
    stub_request(method, "http://apitest"+path).
      to_return(status: status, headers: headers, body: body)
  end

end 
