require 'json'
require 'net/http'
require 'uri'

class BroadbandAPI
  def query_demographics_by_state_name(names)
  end

  # Generic function to hit arbitrary BroadbandMap APIs.
  def query_api(path, params = {})
    uri      = build_uri(path, params)
    response = query_uri(uri)
    parse_response(response)
  end

  private

  BASE_URI = 'https://www.broadbandmap.gov/broadbandmap'
  DEFAULT_PARAMS = {'format' => 'json'}
  def build_uri(path, params)
    encoded_path = path.map { |piece| URI.encode(piece) }

    # URI#build exists, but since it doesn't actually handle joining slashes
    # together it's actually harder to use than String#join, and then call
    # URI#parse ourselves.
    uri = URI.parse([BASE_URI, *encoded_path].join('/'))

    # Encode any parameters on the end of the request.
    uri.query = URI.encode_www_form(DEFAULT_PARAMS.merge(params))
    uri
  end

  # Make an HTTP request to a specified URI, ensuring the response is
  # successful.
  def query_uri(uri)
    response = Net::HTTP.get_response(uri)

    # We should check to make sure we received a valid response
    # before returning.
    unless response.kind_of?(Net::HTTPSuccess)
      fail("Failed to request URI #{uri}, got a #{response.class} error.")
    end

    response.body
  end

  # Given a response from an HTTP call, attempt to parse it as JSON and ensure
  # the basic results object exists.
  def parse_response(response)
    json = JSON.parse(response)
    unless json.key?('Results')
      fail('Query response is missing the expected results!')
    end
    json['Results']
  rescue JSON::JSONError => e
    fail('Could not parse response string as valid JSON!')
  end
end
