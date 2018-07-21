# frozen_string_literal: true

namespace :letsencrypt do
  desc 'Renew the certificates will epxired'
  task renew: :environment do
    count = 0
    failed = 0
    LetsEncrypt::Certificate.renewable.each do |certificate|
      count += 1
      if certificate.renew
        certificate.renewal_attempts = 0
        certificate.save!
        next
      end
      failed += 1
      puts "Could not renew domain: #{certificate.domain}"
      certificate.renewal_attempts += 1
      certificate.save!
    end

    puts "Total #{count} domains should renew, and #{failed} domains cannot be renewed."
  end
end
