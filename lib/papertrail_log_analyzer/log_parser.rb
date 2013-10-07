module PapertrailLogAnalyzer
  class LogParser
    def self.parse(events)
      results = {
        :number => 0,
        :duration_times => [],
        :db_times => [],
        :view_times => [],
      }

      events.each do |event|
        line = event.to_s
        next unless line =~ /\s(GET|POST|PUT|DELETE)\s/

        duration = parse_param(line, 'duration')
        results[:duration_times].push(duration) unless duration.nil?

        db = parse_param(line, 'db')
        results[:db_times].push(db) unless db.nil?

        view = parse_param(line, 'view')
        results[:view_times].push(view) unless view.nil?

        results[:number] += 1
      end

      results
    end

    def self.parse_param(line, param)
      regex = get_regex(param)
      if line =~ regex
        return $1.to_i
      end

      return nil
    end

    def self.get_regex(param)
      Regexp.new("#{Regexp.escape(param)}=(\\d+)ms")
    end
  end
end
