# frozen_string_literal: true

module CepService
  class Exception < StandardError
    def initialize(message, status)
      super(message)
      @status = status
    end
    attr_reader :status
  end
end
