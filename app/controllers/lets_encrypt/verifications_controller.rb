# frozen_string_literal: true

require_dependency 'lets_encrypt/application_controller'

module LetsEncrypt
  TEXT_OR_PLAIN = Rails::VERSION::MAJOR > 4 || (
    Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR >= 1
  ) ? :plain : :text

  # :nodoc:
  class VerificationsController < ApplicationController
    def show
      return render_verification_string if certificate.present?
      render TEXT_OR_PLAIN => 'Verification not found', status: 404
    end

    protected

    def render_verification_string
      render TEXT_OR_PLAIN => certificate.verification_string
    end

    def certificate
      LetsEncrypt::Certificate.find_by(verification_path: filename)
    end

    def filename
      ".well-known/acme-challenge/#{params[:verification_path]}"
    end
  end
end
