class ImportJob < ApplicationJob
  queue_as :google_import

  def perform
    Country.all.each do |country|
      Fetchers::GoogleFetcherService.call(langs: %i[en ja], country: country).call
      #
      # Add other fetchers here...
      #
    end
  end
end
