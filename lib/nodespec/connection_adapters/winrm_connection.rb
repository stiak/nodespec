require 'nodespec/verbose_output'
require 'nodespec/runtime_gem_loader'

module NodeSpec
  module ConnectionAdapters
    class WinrmConnection
      include VerboseOutput
      DEFAULT_PORT = 5985
      DEFAULT_TRANSPORT = :plaintext
      DEFAULT_TRANSPORT_OPTIONS = {disable_sspi: true}
      
      attr_reader :session

      def initialize(hostname, options = {})
        opts = options.dup
        port = opts.delete('port') || DEFAULT_PORT
        @endpoint = "http://#{hostname}:#{port}/wsman"

        if opts.has_key?('transport')
          @transport = opts.delete('transport').to_sym
          @options = opts
        else
          @transport = DEFAULT_TRANSPORT
          @options = DEFAULT_TRANSPORT_OPTIONS.merge(opts)
        end
      end

      def bind_to(configuration)
        current_session = configuration.winrm
        if current_session.nil? || current_session.endpoint != @endpoint
          RuntimeGemLoader.require_or_fail('winrm') do
            verbose_puts "\nConnecting to #{@endpoint}..."
            current_session = WinRM::WinRMWebService.new(@endpoint, @transport, @options)
          end

          configuration.winrm = current_session
        end
        @session = current_session
      end
    end
  end
end