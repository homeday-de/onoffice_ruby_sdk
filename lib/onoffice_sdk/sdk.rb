# frozen_string_literal: true

module OnOfficeSDK
  # Main SDK client for the onOffice API.
  class SDK
    ACTION_ID_READ   = 'urn:onoffice-de-ns:smart:2.5:smartml:action:read'
    ACTION_ID_CREATE = 'urn:onoffice-de-ns:smart:2.5:smartml:action:create'
    ACTION_ID_MODIFY = 'urn:onoffice-de-ns:smart:2.5:smartml:action:modify'
    ACTION_ID_GET    = 'urn:onoffice-de-ns:smart:2.5:smartml:action:get'
    ACTION_ID_DO     = 'urn:onoffice-de-ns:smart:2.5:smartml:action:do'
    ACTION_ID_DELETE = 'urn:onoffice-de-ns:smart:2.5:smartml:action:delete'

    RELATION_TYPE_BUYER   = 'urn:onoffice-de-ns:smart:2.5:relationTypes:estate:address:buyer'
    RELATION_TYPE_TENANT  = 'urn:onoffice-de-ns:smart:2.5:relationTypes:estate:address:renter'
    RELATION_TYPE_OWNER   = 'urn:onoffice-de-ns:smart:2.5:relationTypes:estate:address:owner'
    MODULE_ADDRESS        = 'address'
    MODULE_ESTATE         = 'estate'
    MODULE_SEARCHCRITERIA = 'searchcriteria'
    RELATION_TYPE_CONTACT_BROKER  = 'urn:onoffice-de-ns:smart:2.5:relationTypes:estate:address:contactPerson'
    RELATION_TYPE_CONTACT_PERSON  = 'urn:onoffice-de-ns:smart:2.5:relationTypes:estate:address:contactPersonAll'
    RELATION_TYPE_COMPLEX_ESTATE_UNITS = 'urn:onoffice-de-ns:smart:2.5:relationTypes:complex:estate:units'
    RELATION_TYPE_ESTATE_ADDRESS_OWNER = 'urn:onoffice-de-ns:smart:2.5:relationTypes:estate:address:owner'

    def initialize(api_call: nil)
      @api_call = api_call || Internal::ApiCall.new
      @api_call.set_server('https://api.onoffice.de/api/')
    end

    def set_api_version(api_version)
      @api_call.set_api_version(api_version)
    end

    def set_api_server(server)
      @api_call.set_server(server)
    end

    def set_http_options(options)
      @api_call.set_http_options(options)
    end

    def call_generic(action_id, resource_type, parameters)
      @api_call.call_by_raw_data(action_id, '', '', resource_type, parameters)
    end

    def call(action_id, resource_id, identifier, resource_type, parameters)
      @api_call.call_by_raw_data(action_id, resource_id, identifier, resource_type, parameters)
    end

    def send_requests(token, secret)
      @api_call.send_requests(token, secret)
    end

    def get_response_array(number)
      @api_call.get_response(number)
    end

    def add_cache(cache)
      @api_call.add_cache(cache)
    end

    def set_caches(cache_instances)
      Array(cache_instances).each { |c| @api_call.add_cache(c) }
    end

    def remove_cache_instances
      @api_call.remove_cache_instances
    end

    def errors
      @api_call.errors
    end
  end
end
