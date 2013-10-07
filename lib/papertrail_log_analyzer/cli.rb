require 'optparse'
require 'yaml'
require 'chronic'
require 'command_line_reporter'

require 'papertrail/cli_helpers'
require 'papertrail_log_analyzer'
require 'papertrail_log_analyzer/log_parser'

module PapertrailLogAnalyzer
  class CLI
    include Papertrail::CliHelpers
    include CommandLineReporter

    attr_reader :options

    def initialize
      @options = {
        :configfile => nil
      }
    end

    def run
      if configfile = find_configfile
        configfile_options = load_configfile(configfile)
        options.merge!(configfile_options)
      end

      OptionParser.new do |opts|
        opts.banner = "Papertrail Log Aanlyzer"

        opts.on("-h", "--help", "Show usage") do |v|
          puts opts
          exit
        end
        opts.on("-c", "--configfile PATH", "Path to config (~/.papertrail.yml)") do |v|
          options[:configfile] = File.expand_path(v)
        end
        opts.on("-t", "--token TOKEN", "Papertrail API token") do |v|
          options[:token] = v
        end
        opts.on("-v", "--verbose", "Show details") do |v|
          options[:verbose] = true
        end
        opts.on("--min-time MIN", "Earliest time to search from.") do |v|
          options[:min_time] = v
        end
        opts.on("--max-time MAX", "Latest time to search from.") do |v|
          options[:max_time] = v
        end

        opts.separator usage
      end.parse!

      if options[:configfile]
        configfile_options = load_configfile(options[:configfile])
        options.merge!(configfile_options)
      end

      query_options = {}

      query_results = PapertrailLogAnalyzer::query(ARGV[0], options, query_options)

      if query_results.events.size > 0
        display_results(PapertrailLogAnalyzer::LogParser.parse(query_results.events))
      else
        puts "No events found"
      end
    end

    def display_results(results)
      table do
        row :header => true do
          column '', :width => 20
          column 'min', :align => 'right'
          column 'max', :align => 'right'
          column 'avg', :align => 'right'
          column 'median', :align => 'right'
        end
        row do
          column 'DB Time'
          show_columns(results[:db_times])
        end
        row do
          column 'View Time'
          show_columns(results[:view_times])
        end
        row do
          column 'Duration Time'
          show_columns(results[:duration_times])
        end
      end

      puts ""
      puts "#{results[:number]} events analyzed. All times are milliseconds."
    end

    def usage
      <<-EOF

  Usage:
    papertrail_log_analyzer [-c papertrail.yml] [--min-time mintime] [--max-time maxtime] [query]

  Examples:
    papertrail_log_analyzer something
    papertrail_log_analyzer 1.2.3 Failure
    papertrail_log_analyzer "connection refused"
    papertrail_log_analyzer "(www OR db) (nginx OR pgsql) -accepted"
    papertrail_log_analyzer --min-time 'yesterday at noon' --max-time 'today at 4am'

  EOF
    end

    private

    def median(array)
      sorted = array.sort
      len = sorted.length
      return (sorted[(len - 1) / 2] + sorted[len / 2]) / 2
    end

    def show_columns(values)
      column values.min
      column values.max
      column (values.inject(:+).to_f / values.size).round(2)
      column median(values)
    end
  end
end
