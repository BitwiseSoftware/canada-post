require 'base64'
require 'httparty'
require 'oga'

class CanadaPost
  def initialize(user, pass, development = true)
    @user = user
    @pass = pass

    if development
      @base_url = 'https://ct.soa-gw.canadapost.ca/'
    else
      @base_url = 'https://soa-gw.canadapost.ca/'
    end
  end

  def get_rate(origin, destination, shipment)
    headers = {
      'Accept' => 'application/vnd.cpc.ship.rate-v3+xml',
      'Content-Type' => 'application/vnd.cpc.ship.rate-v3+xml',
      'Accept-language' => 'en-CA'
    }

    # Not fully working yet...
    # Build request XML
    document = Oga::XML::Document.new(name: 'xml')

    mailing_scenario = Oga::XML::Element.new(
      name: 'mailing-scenario',
      attributes: [Oga::XML::Attribute.new(
        name: :xmlns, value: 'http://www.canadapost.ca/ws/ship/rate-v3'
      )]
    )

    parcel = Oga::XML::Element.new(name: 'parcel-characteristics')
    weight = Oga::XML::Element.new(name: 'weight')
    weight.inner_text = shipment[:weight].to_s
    parcel.children << weight
    mailing_scenario.children << parcel

    destination_xml = Oga::XML::Element.new(name: 'destination')
    domestic = Oga::XML::Element.new(name: 'domestic')
    destination_postal_code = Oga::XML::Element.new(name: 'postal-code')
    destination_postal_code.inner_text = destination
    domestic.children << destination_postal_code
    destination_xml.children << domestic
    mailing_scenario.children << destination_xml

    origin_postal_code = Oga::XML::Element.new(name: 'origin-postal-code')
    origin_postal_code.inner_text = origin
    mailing_scenario.children << origin_postal_code

    quote_type = Oga::XML::Element.new(name: 'quote-type')
    quote_type.inner_text = 'counter'
    mailing_scenario.children << quote_type

    document.children << mailing_scenario

    response = HTTParty.post(
      @base_url + 'rs/ship/price', body: document.to_xml, headers: headers,
      verify: false, basic_auth: http_auth
    )

    # Parse response
    Oga.parse_xml(response.to_s).xpath(
      'xmlns:price-quotes/xmlns:price-quote'
    ).map do |quote|
      name = quote.at_xpath('xmlns:service-name').text
      cost = quote.at_xpath('xmlns:price-details/xmlns:due').text

      service_standard = quote.at_xpath('xmlns:service-standard')
      guaranteed = service_standard.at_xpath('xmlns:guaranteed-delivery').text
      days = service_standard.at_xpath('xmlns:expected-transit-time').text
      date = service_standard.at_xpath('xmlns:expected-delivery-date').text

      {name: name, cost: cost, transit: {
        guaranteed: guaranteed, days: days, date: date
      }}
    end
  end

  def create_label

  end

private
  def http_auth
    {username: @user, password: @pass}
  end
end

