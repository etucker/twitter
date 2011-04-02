require 'faraday_middleware'
require 'faraday/multipart'
require 'faraday/oauth'
require 'faraday/raise_http_4xx'
require 'faraday/raise_http_5xx'

module Twitter
  # @private
  module Connection
    private

    def connection(raw=false)
      options = {
        :headers => {'Accept' => "application/#{format}", 'User-Agent' => user_agent},
        :proxy => proxy,
        :ssl => {:verify => false},
        :url => api_endpoint,
      }

      Faraday.new(options) do |builder|
        builder.use Faraday::Request::Multipart
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Request::OAuth, authentication if authenticated?
        builder.use Faraday::Response::RaiseHttp4xx
        builder.use Faraday::Response::Mashify unless raw
        unless raw
          case format.to_s.downcase
          when 'json'
            builder.use Faraday::Response::ParseJson
          when 'xml'
            builder.use Faraday::Response::ParseXml
          end
        end
        builder.use Faraday::Response::RaiseHttp5xx
        builder.adapter(adapter)
      end
    end
  end
end
