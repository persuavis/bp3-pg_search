# frozen_string_literal: true

require 'rails/railtie'

module Bp3
  module PgSearch
    class Railtie < Rails::Railtie
      initializer 'bp3.pg_search.railtie.register' do |app|
        app.config.after_initialize do
          ::PgSearch::Document # preload
          module ::PgSearch
            class Document
              include Bp3::Core::Rqid
              include Bp3::Core::Sqnr
              include Bp3::Core::Tenantable
              include Bp3::Core::Displayable
              include Bp3::Core::Ransackable

              configure_tenancy
              use_sqnr_for_ordering

              private

              def version_filter_mask
                '[FILTERED][PS]'
              end
            end
          end
        end
      end
    end
  end
end
