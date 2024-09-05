require 'spec_helper'
require 'webmock/rspec'
require 'faye/websocket'
require 'eventmachine'
require_relative '../../lib/bitfinex'

RSpec.describe 'Bitfinex::WSv2 Integration' do
  let(:client) do
    Bitfinex::WSv2.new({
      url: 'ws://localhost:8080/ws/2',
    })
  end

  before do
    stub_request(:any, 'ws://localhost:8080/ws/2').to_return(body: '', status: 200)
  end

  it 'connects to WebSocket' do
    EM.run {
      mock_server = EM.start_server('0.0.0.0', 8080) do |conn|
        conn.instance_eval do
          def post_init
            @ws = Faye::WebSocket::Server.new(self)
            @ws.on :open do |event|
              @ws.send('{"event":"info","version":2,"serverId":"60916660-db0f-4519-b4cd-be8d4c745b24","platform":{"status":1}}')
            end
            @ws.on :message do |event|
              @ws.send('{"event":"subscribed","channel":"ticker","pair":"tBTCUSD"}')
            end
            @ws.on :close do |event|
              close_connection
              EM.stop
            end
          end

          def receive_data(data)
            @ws.receive(data)
          end
        end
      end

      expect { client.open! }.not_to raise_error
      EM.stop_server(mock_server)
      EM.stop
    }
  end

  it 'subscribes to a channel' do
    EM.run {
      mock_server = EM.start_server('0.0.0.0', 8080) do |conn|
        conn.instance_eval do
          def post_init
            @ws = Faye::WebSocket::Server.new(self)
            @ws.on :open do |event|
              @ws.send('{"event":"info","version":2,"serverId":"60916660-db0f-4519-b4cd-be8d4c745b24","platform":{"status":1}}')
            end
            @ws.on :message do |event|
              @ws.send('{"event":"subscribed","channel":"ticker","pair":"tBTCUSD"}')
            end
            @ws.on :close do |event|
              close_connection
              EM.stop
            end
          end

          def receive_data(data)
            @ws.receive(data)
          end
        end
      end

      client.on(:open) do
        client.subscribe_order_book('tBTCUSD', 'R0', '25')
      end

      expect { client.open! }.not_to raise_error
      EM.stop_server(mock_server)
      EM.stop
    }
  end
end
