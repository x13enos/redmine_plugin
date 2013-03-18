module Stalactite
  module Hooks
    class Issue < Redmine::Hook::ViewListener

      render_on :view_issues_form_details_bottom, :partial => "issues/timestamp_fields"
      render_on :view_issues_show_details_bottom, :partial => "issues/show_timestamp_fields"

      def controller_issues_new_before_save(context={})
        context[:issue].started_at = context[:params][:issue][:started_at]
        context[:issue].finished_at = context[:params][:issue][:finished_at]
      end
    end

  end
end