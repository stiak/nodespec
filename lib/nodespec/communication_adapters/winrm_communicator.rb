require 'nodespec/verbose_output'
require 'nodespec/runtime_gem_loader'
require 'nodespec/backend_proxy'

module NodeSpec
  module CommunicationAdapters
    class WinrmCommunicator
      include VerboseOutput
      DEFAULT_PORT = 5985
      DEFAULT_TRANSPORT = :plaintext
      DEFAULT_TRANSPORT_OPTIONS = {disable_sspi: true}

      attr_reader :session

      def initialize(hostname, options = {})
        @hostname = hostname
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
        @options = @options.inject({}) {|h,(k,v)| h[k.to_sym] = v; h}
      end

      def bind_to(configuration)
        if configuration.ssh
          close_ssh_session(configuration.ssh)
          configuration.ssh = nil
        end

        current_session = configuration.winrm
        if current_session.nil? || current_session.endpoint != @endpoint
          current_session = start_winrm_session
          configuration.winrm = current_session
          configuration.host = @hostname
        end
        @session = current_session
      end

      def backend_proxy
        BackendProxy.create(:winrm, @session)
      end

      def backend
        :winrm
      end

      private

      def close_ssh_session(session)
        msg = "\nClosing connection to #{session.host}"
        msg << ":#{session.options[:port]}" if session.options[:port]
        verbose_puts msg
        session.close
      end

      def start_winrm_session
        RuntimeGemLoader.require_or_fail('winrm') do
          verbose_puts "\nConnecting to #{@endpoint}..."
          WinRM::WinRMWebService.new(@endpoint, @transport, @options)
        end
      end
    end
  end
end