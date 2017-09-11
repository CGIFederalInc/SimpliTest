module CustomDateHelpers
  def calculated_date_from(date_rule)
    # Takes strings like "Today's Date", "4 days ago", "5 days since" etc. and
    # returns a calculated date in the default_date_format
    potential_date_formats = /[0-9]+\/[0-9]+\/[0-9]+/x
    first_and_last_regex = /the (nearest|first|last) (.*)/
    date =  case date_rule
            when potential_date_formats
              date_rule
            when /Today's Date/i
              Date.today
            when /(\d+) days (ago|since)/i
              number_of_days = $1.to_i rescue nil
              time_travel_method = $2.downcase.to_sym
              raise "Invalid number of days. Please enter a valid number" if number_of_days.nil?
              number_of_days.send(:days).send(time_travel_method)
            when first_and_last_regex
              first_and_last_date_rule(rule)
            end
    date.respond_to?(:strftime) ? date.strftime(default_date_format) : date
  end

  def first_and_last_date_rule(phrase)
    # Takes a phrase like "the first day of the month" or "last day of the
    # previous month" and returns a calculated date in the default_date_format
    case phrase
    when /the (first|last) day of the month/i
      Date.today.send(beginning_or_end($1))
    when /the (first|last) day of next month/i
      1.month.since.send(beginning_or_end($1))
    when /the (first|last) day of previous month/i
      1.month.ago.send(beginning_or_end($1))
    when /the (first|last) day of (.*)/i
      date_from_phrase($1, $2)
    when /the nearest (first|last) day of month/i
      rule = Date.today.day >= 15 ? "the #{$1} day of next month" : "the #{$1} day of the month"
      calculated_date_from(rule)
    end
  end

  def beginning_or_end(first_or_last)
    first_or_last == 'first' ? :beginning_of_month : :end_of_month
  end

  def default_date_format
    format_for_strftime SimpliTest.config_settings['DEFAULT_DATE_FORMAT']
  end

  def date_from_phrase(first_or_last, month)
    month_name = month.downcase.camelize
    month = Date::MONTHNAMES.index(month_name)
    if month.nil?
      raise "Oops you provided an invalid month name. Please use a valid month name from January to December"
    end
      date = Date.parse("#{month}/1") #mm/dd in current year
      date = date.send(:end_of_month) if first_or_last == 'last'
  end

  def format_for_strftime(string)
    string.gsub('mm', '%m').gsub('dd', '%d').gsub('yyyy', '%Y').gsub('yy', '%y')
  end
end

World(CustomDateHelpers)
