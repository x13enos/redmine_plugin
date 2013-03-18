CalendarsHelper.module_eval do
  def link_to_previous_week(day, options={})
    link_to_content_update(l(:calendar_previous_week), params.merge(:current_day => day, :type_week_navigate=> 'prev'))
  end

  def link_to_next_week(day, options={})
    link_to_content_update(l(:calendar_next_week), params.merge(:current_day => day, :type_week_navigate => 'next'))
  end

  def week_period(day)
    (day.day - 1).to_s + '-' + (day + 5.days).day.to_s + ' ' + l('date.month_names')[@day.month] + ' ' + @day.year.to_s
  end

end