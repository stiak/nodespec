require 'specinfra/helper'
require 'nodespec/connection_adapters'
require 'nodespec/backends'
%w[exec cmd ssh winrm].each {|f| require_relative "command_helpers/#{f}"}

module NodeSpec
  class Node
    attr_reader :os, :remote_connection, :name

    def initialize(node_name, options = nil)
      options = (options || {}).dup
      @name = node_name
      @os = options.delete('os')
      adapter_name = options.delete('adapter')
      if adapter_name
        adapter = ConnectionAdapters.get(node_name, adapter_name, options)
        @remote_connection = adapter.connection
      end
    end

    def backend
      if @remote_connection
        remote_backend
      else
        local_backend
      end
    end

    def execute_command(command)
      command_helper.execute(command)
    end

    private

    def command_helper
      @command_helper ||= init_command_helper
    end

    def init_command_helper
      if @remote_connection
        CommandHelpers.const_get(remote_backend).new(@remote_connection.session)
      else
        CommandHelpers.const_get(local_backend).new
      end
    end

    def local_backend
      @os == 'Windows' ? Backends::Cmd : Backends::Exec
    end

    def remote_backend
      @os == 'Windows' ? Backends::WinRM : Backends::Ssh
    end
  end
end