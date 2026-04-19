require "shellwords"

module Admin
  class ReportsController < ApplicationController
    before_action :require_admin

    def search_logs
      query = params[:query]
      results = `grep -r #{Shellwords.shellescape(query)} log/`

      render plain: results
    end

  end
end
