require "papertrail_log_analyzer/version"
require "papertrail/connection"

module PapertrailLogAnalyzer
  def self.query(query_string, connection_options, query_options)
    connection = Papertrail::Connection.new(connection_options)
    return connection.query(query_string, query_options).search
  end
end
