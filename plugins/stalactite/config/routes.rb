# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


RedmineApp::Application.routes.draw do
  match '/projects/:project_id/issues/calendar/search_free_time', :to => 'calendars#search_free_time'
end