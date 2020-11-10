# frozen_string_literal: true

module LetsEncrypt
  # :nodoc:
  module CertificateVerifiable
    extend ActiveSupport::Concern

    # Returns true if verify domain is succeed.
    def verify
      start_authorize
      start_challenge
      wait_verify_status
      check_verify_status
    rescue Acme::Client::Error => e
      retry_on_verify_error(e)
    end

    private

    def start_authorize
      @order = LetsEncrypt.client.new_order(identifiers: [domain])
      authorization = @order.authorizations.first
      @challenge = authorization.http

      self.verification_path = @challenge.filename
      self.verification_string = @challenge.file_content
      save!
    end

    def start_challenge
      logger.info "Attempting verification of #{domain}"
      @challenge.request_validation
    end

    def wait_verify_status
      checks = 0
      until @challenge.status != 'pending'
        checks += 1
        if checks > 30
          logger.info "#{domain}: Status remained at pending for 30 checks"
          return false
        end
        sleep 1
        @challenge.reload
      end
    end

    def check_verify_status
      unless @challenge.status == 'valid'
        logger.info "#{domain}: Status was not valid (was: #{@challenge.status})"
        return false
      end

      true
    end

    def retry_on_verify_error(e)
      @retries ||= 0
      if e.is_a?(Acme::Client::Error::BadNonce) && @retries < 5
        @retries += 1
        logger.info "#{domain}: Bad nounce encountered. Retrying (#{@retries} of 5 attempts)"
        sleep 1
        verify
      else
        logger.info "#{domain}: Error: #{e.class} (#{e.message})"
        return false
      end
    end
  end
end
