require 'redmine'


Redmine::Plugin.register :stalactite do
  name 'Stalactite plugin'
  author 'Andres Sild'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  project_module :calendar do |map|
    map.permission :search_free_time, :calendars => :search_free_time, :read => true
  end
end

require 'stalactite/hooks/issue'
require 'patches/calendars_controller_patch'
require 'patches/redmine_helper_calendar_patch'
require 'patches/calendars_helper_patch'
require 'patches/issues_controller_patch'

ActionDispatch::Callbacks.to_prepare do
  IssuesHelper.send(:include, Patches::IssuesHelperPatch)
end


