module Fetchers
  class BaseFetcherService < ::BaseService
    def initialize(**args)
      args.each do |key, val|
        instance_variable_set("@#{key}", val)
      end
    end
  end
end
