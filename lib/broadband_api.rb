require 'json'
require 'net/http'
require 'uri'

class BroadbandAPI
  # Useful for querying a states FIPS ID from it's name.
  def query_census_by_state_name(name)
    query_api(['census', 'state', name], {})
  end

  def query_demographics_by_state_name(*names)
    # You could avoid this loop by calling a different API that lists all the
    # states in one go, especially when the input set (i.e., states in the US)
    # is so constrained and the results are highly cacheable.
    all_fips = names.map do |name|
      states = query_census_by_state_name(name)['state']

      # This is a prefix search API - there's no guarantee that any of the
      # results match if we passed in bad input.
      state = states.find { |st| st['name'] == name }
      fail("No state '#{name}' can be found!") unless state

      state['fips']
    end

    # Luckily the next call batches. :)
    query_demographics_by_geography_type_and_id('state', all_fips)
  end

  # We don't actually use this for anything but states, but we could.
  def query_demographics_by_geography_type_and_id(type, *ids)
    query_api(
      # We'll use the latest data.
      ['demographic', 'jun2014', type, 'ids', ids.join(',')],
      # The API in use doesn't appear to support any kind of paging. Therefore,
      # we *must* request everything at once. :(
      # This isn't a huge deal for states, given how few of them there are.
      {'maxResults' => ids.size}
    )
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
