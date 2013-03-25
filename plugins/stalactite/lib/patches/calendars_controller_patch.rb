CalendarsController.class_eval do
  def show
    if params[:year] and params[:year].to_i > 1900
      @year = params[:year].to_i
      if params[:month] and params[:month].to_i > 0 and params[:month].to_i < 13
        @month = params[:month].to_i
      end
    end
    @year ||= Date.today.year
    @month ||= Date.today.month
    @day = if (params[:type_week_navigate] == 'next' || params[:type_week_navigate] == 'prev') && params[:current_day]
      day = params[:type_week_navigate] == 'next' ? params[:current_day].to_date + 7.days : params[:current_day].to_date - 7.days
      @month = day.month
      @year = day.year
      day
    elsif params[:current_day]
      params[:current_day].to_date
    else
      Date.today.beginning_of_week
    end


    @type_period = if params[:type_period] && params[:type_period] == 'week'
      :week
    else
      :month
    end

    @calendar = Redmine::Helpers::Calendar.new(Date.civil(@year, @month, @day.day), current_language, @type_period)
    retrieve_query
    @query.group_by = nil
    if @query.valid?
      events = []
      events += @query.issues(:include => [:tracker, :assigned_to, :priority],
                              :conditions => ["((start_date BETWEEN ? AND ?) OR (due_date BETWEEN ? AND ?))", @calendar.startdt, @calendar.enddt, @calendar.startdt, @calendar.enddt]
                              )
      events += @query.versions(:conditions => ["effective_date BETWEEN ? AND ?", @calendar.startdt, @calendar.enddt])

      @calendar.events = events
    end

    if params[:type_period] && params[:type_period] == 'day'
      date = params[:calendar_date].to_date
      project_id = Project.find_by_identifier(params[:project_id]).id
      issues = Issue.where('project_id = ? AND start_date = ?', project_id, date)
      @day_events = {}
      @day_events["without_time"] = []
      ('0'..'23').each{|time| @day_events[time] = [] }
      issues.each do |issue|
        if issue.started_at.nil?
          @day_events["without_time"] << issue
        else
          @day_events[issue.started_at.hour.to_s] << issue
        end
      end
    end
    render :action => 'show', :layout => false if request.xhr?
  end

  def search_free_time
    @users = User.order('id ASC')
    puts @users.inspect
    @date_start = params[:search_time_from]
    @date_end = params[:search_time_by]
    @specified_period_start = params[:search_specified_from]
    @specified_period_end = params[:search_specified_by]
    @search_type = params[:search_time_type]
    unless params[:time_value].blank?
      time_value_array = params[:time_value].split(':')
      @time_value = time_value_array[0].to_i
    end
    @free_time = {}
    if params[:users] && @date_start && @date_end && @search_type
      params[:users].each do |user_id, value|
        user = User.find(user_id.to_i)
        @free_time[user] = {}
        user_issues = Issue.where('assigned_to_id = ? AND started_at BETWEEN ? AND ?', user_id.to_i, @date_start.to_date.beginning_of_day, @date_end.to_date.end_of_day).order('started_at ASC').group_by{|issue| issue.started_at.day}
        (@date_start.to_date..@date_end.to_date).each do |day|
          if @search_type == 'idle_time' && @time_value
            @free_time[user][day] = search_idle_time_in_day(day, user, user_issues, @time_value)
          elsif @search_type == 'specified_period' && @specified_period_start && @specified_period_end
            @free_time[user][day] = search_specified_period_in_day(day,user,user_issues, @specified_period_start, @specified_period_end)
          end
        end
      end
    end
    puts @free_time
  end

  private

  def search_idle_time_in_day(day, user, user_issues, time_value)
    free_time = []
    time_now = DateTime.new(day.year, day.month, day.day, 8)
    if user_issues[day.day]
      user_issues[day.day].each do |issue|
        if issue.started_at.hour - time_now.hour >= time_value
          free_time << time_now.strftime('%R') + ' - ' + issue.started_at.strftime('%R')
        end
        time_now = issue.finished_at
      end
      if 18 - user_issues[day.day].last.finished_at.hour >= time_value
        free_time << user_issues[day.day].last.finished_at.strftime('%R') + ' - 18:00'
      end
    else
      free_time << time_now.strftime('%R') + ' - 18:00'
    end
    free_time
  end

  def search_specified_period_in_day(day, user, user_issues, period_start, period_end)
    period_start = DateTime.new(day.year, day.month, day.day, period_start.split(':')[0].to_i)
    period_end = DateTime.new(day.year, day.month, day.day, period_end.split(':')[0].to_i)
    status = true
    if user_issues[day.day]
      user_issues[day.day].each do |issue|
        status = false if (issue.started_at >= period_start && issue.started_at < period_end) || (issue.finished_at <= period_end && issue.finished_at > period_start)
      end
    end
    true if status
  end

end