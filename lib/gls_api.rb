require 'faraday'
require 'json'
require 'digest'
require 'base64'
require 'time'

class GlsApi
  API_BASE_URL = 'https://api.mygls.si'
  DEFAULT_TIMEOUT = 600
  
  attr_reader :username, :format, :client_number
  
  def initialize(username:, password:, client_number:, fmt: :json, timeout: DEFAULT_TIMEOUT)
    @username = username
    @password = password
    @client_number = client_number
    @format = fmt
    @timeout = timeout
    @connection = build_connection
  end
  
  # Print labels directly from the service
  def print_labels(parcels:, print_position: 1, show_print_dialog: false)
    service_name = 'ParcelService'
    method_name = 'PrintLabels'
    
    request_body = build_request(
      method_name: method_name,
      data: { ParcelList: parcels },
      additional_params: { PrintPosition: print_position, ShowPrintDialog: show_print_dialog }
    )
    
    response = make_request(service_name: service_name, method: method_name, body: request_body)
    extract_labels(response, method_name)
  end
  
  # Prepare labels and get parcel IDs
  def prepare_labels(parcels:)
    service_name = 'ParcelService'
    method_name = 'PrepareLabels'
    
    request_body = build_request(
      method_name: method_name,
      data: { ParcelList: parcels }
    )
    
    response = make_request(service_name: service_name, method: method_name, body: request_body)
    extract_parcel_ids(response)
  end
  
  # Get previously prepared labels by parcel IDs
  def get_printed_labels(parcel_ids:, print_position: 1, show_print_dialog: false)
    service_name = 'ParcelService'
    method_name = 'GetPrintedLabels'
    
    request_body = build_request(
      method_name: method_name,
      data: { ParcelIdList: parcel_ids },
      additional_params: { PrintPosition: print_position, ShowPrintDialog: show_print_dialog }
    )
    
    response = make_request(service_name: service_name, method: method_name, body: request_body)
    extract_labels(response, method_name)
  end
  
  # Get parcel list by date range
  def get_parcel_list(pickup_date_from:, pickup_date_to:, print_date_from: nil, print_date_to: nil)
    service_name = 'ParcelService'
    method_name = 'GetParcelList'
    
    data = {
      PickupDateFrom: format_date(pickup_date_from),
      PickupDateTo: format_date(pickup_date_to),
      PrintDateFrom: print_date_from ? format_date(print_date_from) : nil,
      PrintDateTo: print_date_to ? format_date(print_date_to) : nil
    }
    
    request_body = build_request(method_name: method_name, data: data)
    response = make_request(service_name: service_name, method: method_name, body: request_body)
    
    parse_response(response)
  end
  
  # Get parcel statuses and POD (Proof of Delivery)
  def get_parcel_statuses(parcel_number:, return_pod: true, language_iso_code: 'HU')
    service_name = 'ParcelService'
    method_name = 'GetParcelStatuses'
    
    data = {
      ParcelNumber: parcel_number,
      ReturnPOD: return_pod,
      LanguageIsoCode: language_iso_code
    }
    
    request_body = build_request(method_name: method_name, data: data)
    response = make_request(service_name: service_name, method: method_name, body: request_body)
    
    if return_pod
      extract_pod(response)
    else
      parse_response(response)
    end
  end
  
  private
  
  def build_connection
    Faraday.new(url: API_BASE_URL) do |conn|
      conn.request :url_encoded
      conn.adapter Faraday.default_adapter
      conn.options.timeout = @timeout
      conn.options.open_timeout = @timeout
      conn.ssl.verify = false # As per original PHP code
    end
  end
  
  def encoded_password
    hash = Digest::SHA512.digest(@password)
    
    if @format == :json
      # JSON format: array of byte integers (NOT Base64 string!)
      hash.bytes.to_a
    else
      # XML format: Base64 string
      Base64.strict_encode64(hash)
    end
  end
  
  def format_date(date)
    time = date.is_a?(Time) ? date : Time.parse(date.to_s)
    
    if @format == :json
      # JSON format: /Date(milliseconds)/
      "/Date(#{time.to_i * 1000})/"
    else
      # XML format: ISO 8601
      time.strftime('%Y-%m-%dT%H:%M:%S')
    end
  end
  
  def build_request(method_name:, data:, additional_params: {})
    auth_params = {
      Username: @username,
      Password: encoded_password,
      WebshopEngine: 'Custom'
    }
    
    request_data = auth_params.merge(data).merge(additional_params)
    
    if @format == :json
      build_json_request(method_name, request_data)
    else
      build_xml_request(method_name, request_data)
    end
  end
  
  def build_json_request(method_name, data)
    JSON.generate(data)
  end
  
  def build_xml_request(method_name, data)
    # Simplified XML builder - in production, consider using Nokogiri or Builder
    xml_parts = ["<#{method_name}Request"]
    xml_parts << 'xmlns="http://schemas.datacontract.org/2004/07/GLS.MyGLS.ServiceData.APIDTOs.LabelOperations"'
    xml_parts << 'xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
    
    xml_parts << '<ClientNumberList'
    xml_parts << 'xmlns="http://schemas.datacontract.org/2004/07/GLS.MyGLS.ServiceData.APIDTOs.Common"'
    xml_parts << 'xmlns:a="http://schemas.microsoft.com/2003/10/Serialization/Arrays"/>'
    xml_parts << "<Password xmlns=\"http://schemas.datacontract.org/2004/07/GLS.MyGLS.ServiceData.APIDTOs.Common\">#{data[:Password]}</Password>"
    xml_parts << "<Username xmlns=\"http://schemas.datacontract.org/2004/07/GLS.MyGLS.ServiceData.APIDTOs.Common\">#{data[:Username]}</Username>"
    
    # Add other data elements (simplified - expand as needed)
    data.except(:Username, :Password).each do |key, value|
      xml_parts << "<#{key}>#{value}</#{key}>" unless value.nil?
    end
    
    xml_parts << "</#{method_name}Request>"
    xml_parts.join('').gsub(/\s+/, '')
  end
  
  def make_request(service_name:, method:, body:)
    format_path = @format == :json ? 'json' : 'xml'
    url = "/#{service_name}.svc/#{format_path}/#{method}"
    content_type = @format == :json ? 'application/json' : 'text/xml'
    
    response = @connection.post(url) do |req|
      req.headers['Content-Type'] = content_type
      req.body = body
    end
    
    handle_response(response)
  end
  
  def handle_response(response)
    case response.status
    when 200
      response.body
    when 401
      raise GLSAPIError, 'Unauthorized - check your credentials'
    else
      raise GLSAPIError, "HTTP #{response.status}: #{response.body}"
    end
  end
  
  def parse_response(response)
    if @format == :json
      JSON.parse(response)
    else
      response # Return raw XML - in production, parse with Nokogiri
    end
  end
  
  def extract_labels(response, method_name)
    if @format == :json
      parsed = JSON.parse(response)
      error_key = "#{method_name}ErrorList"
      
      if parsed[error_key]&.empty? && parsed['Labels']&.any?
        parsed['Labels'].pack('C*')
      else
        raise GLSAPIError, "Errors in response: #{parsed[error_key]}"
      end
    else
      extract_xml_node(response, 'Labels', decode_base64: true)
    end
  end
  
  def extract_pod(response)
    if @format == :json
      parsed = JSON.parse(response)
      
      if parsed['GetParcelStatusErrors']&.empty? && parsed['POD']&.any?
        parsed['POD'].pack('C*')
      else
        raise GLSAPIError, "Errors in response: #{parsed['GetParcelStatusErrors']}"
      end
    else
      extract_xml_node(response, 'POD', decode_base64: true)
    end
  end
  
  def extract_parcel_ids(response)
    if @format == :json
      parsed = JSON.parse(response)
      
      if parsed['PrepareLabelsError']&.empty? && parsed['ParcelInfoList']&.any?
        parsed['ParcelInfoList'].map { |info| info['ParcelId'] }
      else
        raise GLSAPIError, "Errors in response: #{parsed['PrepareLabelsError']}"
      end
    else
      # Extract ParcelId from XML - simplified version
      response.scan(/<ParcelId>(.*?)<\/ParcelId>/).flatten
    end
  end
  
  def extract_xml_node(xml, node_name, decode_base64: false)
    start_tag = "<#{node_name}>"
    end_tag = "</#{node_name}>"
    
    start_pos = xml.index(start_tag)
    return nil unless start_pos
    
    start_pos += start_tag.length
    end_pos = xml.index(end_tag, start_pos)
    content = xml[start_pos...end_pos]
    
    decode_base64 ? Base64.decode64(content) : content
  end
end

class GLSAPIError < StandardError; end

# Example usage:
# client = GlsApi.new(
#   client_number: 100000001,
#   username: 'myglsapitest@test.mygls.hu',
#   password: '1pImY_gls.hu',
#   format: :json
# )
#
# parcels = [{
#   ClientNumber: 100000001,
#   ClientReference: 'TEST PARCEL',
#   CODAmount: 0,
#   Content: 'CONTENT',
#   Count: 1,
#   DeliveryAddress: {
#     City: 'Alsónémedi',
#     ContactEmail: 'something@anything.hu',
#     ContactName: 'Contact Name',
#     ContactPhone: '+36701234567',
#     CountryIsoCode: 'HU',
#     HouseNumber: '2',
#     Name: 'Delivery Address',
#     Street: 'Európa u.',
#     ZipCode: '2351'
#   },
#   PickupAddress: { ... },
#   PickupDate: Time.now,
#   ServiceList: [{ Code: 'PSD', PSDParameter: { StringValue: '2351-CSOMAGPONT' } }]
# }]
#
# labels = client.print_labels(parcels: parcels)
# File.write('labels.pdf', labels)