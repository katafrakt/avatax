module Avatax
  class Client
    @namespaces = []
    @connection = nil

    ##
    # Defines a method to access class instance.
    #
    def self.namespace(name)
      converted = name.to_s.split('_').map(&:capitalize).join
      klass = Avatax::Api.const_get(converted)
      @namespaces << klass
    end

    namespace :accounts

    namespace :addresses

    namespace :batches

    namespace :companies

    namespace :contacts

    namespace :definitions

    namespace :items

    namespace :locations

    namespace :nexus

    namespace :settings

    namespace :subscriptions

    namespace :tax_codes

    namespace :tax_rates

    namespace :tax_rules

    namespace :transactions

    namespace :upcs

    namespace :users

    namespace :utilities

    def initialize(args = {})
      @configuration = Avatax::Configuration.new(args)

      @connection = Faraday.new(url: @configuration.base_url) do |conn|
        conn.request :json
        conn.request(
          :basic_auth,
          @configuration.username,
          @configuration.password
        )

        conn.headers = @configuration.headers

        conn.response :json
        conn.response :logger, @configuration.logger

        conn.adapter  Faraday.default_adapter
      end

      create_instances
    end

    private

    def create_instances
      namespaces = self.class.instance_variable_get(:@namespaces)
      namespaces.each do |klass|
        reader = klass.to_s.split('::').last.underscore
        self.class.send(:define_method, reader.to_sym) { klass.new @connection }
      end
    end
  end
end
