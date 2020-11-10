# frozen_string_literal: true

module LetsEncrypt
  # :nodoc:
  module CertificateIssuable
    extend ActiveSupport::Concern

    # Returns true if issue new certificate succeed.
    def issue
      logger.info "Getting certificate for #{domain}"
      create_certificate
      # rubocop:disable Metrics/LineLength
      logger.info "Certificate issued for #{domain} (expires on #{expires_at}, will renew after #{renew_after})"
      # rubocop:enable Metrics/LineLength
      true
    end

    private

    def csr
      private_key = OpenSSL::PKey::RSA.new(key)

      csr = Acme::Client::CertificateRequest.new(
        private_key: private_key,
        subject: { common_name: domain }
      )
    end

    def create_certificate
      @order.finalize(csr: csr)
      while @order.status == 'processing'
        sleep(1)
        @order.reload
      end
      https_cert = @order.certificate

      fullchain = https_cert.split("\n\n")
      cert = OpenSSL::X509::Certificate.new(fullchain.shift)
      self.certificate = cert.to_pem
      self.intermediaries = fullchain.join("\n\n")
      self.expires_at = cert.not_after
      self.renew_after = (expires_at - 1.month) + rand(10).days
      save!
    end
  end
end
