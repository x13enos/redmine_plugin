Redmine::Helpers::Calendar.module_eval do
  def events_on(day)
    events = ((@ending_events_by_days[day] || []) + (@starting_events_by_days[day] || [])).uniq
    @events_without_started_at= events.map{|e| e if e.started_at.nil?}.compact
    @events_with_started_at = events.map{|e| e unless e.started_at.nil? }.compact
    if @events_with_started_at.count > 1
      @events_with_started_at.sort!{|a,b| a.started_at <=> b.started_at}
    end
    (@events_without_started_at + @events_with_started_at).flatten
  end
end