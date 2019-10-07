class ImportJob < ApplicationJob
  queue_as :import

  def perform(fetcher_class, options = nil)
    service = fetcher_class.safe_constantize
    args = { langs: %i[en ja] }
    args[:options] = options if options
    service.call(args)
    #
    # Add other fetchers here...
    #
  end
end
