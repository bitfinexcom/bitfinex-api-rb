class NetHttpSocks < Faraday::Adapter::NetHttp
  SOCKS_SCHEMES = ['socks', 'socks4', 'socks5']

  def net_http_connection(env)
    proxy = env[:request][:proxy]

    net_http_class = if proxy
                       if SOCKS_SCHEMES.include?(proxy[:uri].scheme)
                         Net::HTTP::SOCKSProxy(proxy[:uri].host, proxy[:uri].port)
                       else
                         Net::HTTP::Proxy(proxy[:uri].host, proxy[:uri].port, proxy[:user], proxy[:password])
                       end
                     else
                       Net::HTTP
                     end

    net_http_class.new(env[:url].host, env[:url].port)
  end
end

Faraday::Adapter.register_middleware(net_http_socks: NetHttpSocks)
