module Patches
  module IssuesHelperPatch

    def self.included(base)
      # наследуем родные методы
      base.extend(ClassMethods)
      # расширяем класс своими методами
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        # соединяем методы в цепочку
        alias_method_chain :render_issue_tooltip, :ext
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def render_issue_tooltip_with_ext(issue)
        @cached_label_status ||= l(:field_status)
        @cached_label_start_date ||= l(:field_start_date)
        @cached_label_due_date ||= l(:field_due_date)
        @cached_label_assigned_to ||= l(:field_assigned_to)
        @cached_label_priority ||= l(:field_priority)
        @cached_label_project ||= l(:field_project)
        @cached_label_started_at ||= l(:field_started_at)
        @cached_label_finished_at ||= l(:field_finished_at)

        time_started_at = issue.started_at.blank? ? '' : issue.started_at.strftime('%R')
        time_finished_at = issue.finished_at.blank? ? '' : issue.finished_at.strftime('%R')

       "<br />".html_safe +
      "<strong>#{@cached_label_project}</strong>: #{link_to_project(issue.project)}<br />".html_safe +
      "<strong>#{@cached_label_status}</strong>: #{h(issue.status.name)}<br />".html_safe +
      "<strong>#{@cached_label_start_date}</strong>: #{format_date(issue.start_date)}<br />".html_safe +
      "<strong>#{@cached_label_due_date}</strong>: #{format_date(issue.due_date)}<br />".html_safe +
      "<strong>#{@cached_label_assigned_to}</strong>: #{h(issue.assigned_to)}<br />".html_safe +
      "<strong>#{@cached_label_priority}</strong>: #{h(issue.priority.name)}<br />".html_safe +
      "<strong>#{@cached_label_started_at}</strong>: #{time_started_at}<br />".html_safe +
      "<strong>#{@cached_label_finished_at}</strong>: #{time_finished_at}".html_safe
      end
    end

  end
end