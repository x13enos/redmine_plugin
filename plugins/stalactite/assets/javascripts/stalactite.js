$(function(){

  $('#issue_started_at, #issue_finished_at').datetimepicker({
    dateFormat: 'dd/mm/yy'
  });

  $('#search_time_from, #search_time_by').datepicker({
    dateFormat: 'dd/mm/yy'
  });

  $('#time_value, #search_specified_from, #search_specified_by').timepicker()

  $('.user_time_results_link').click(function(e){
    e.preventDefault()
    image = $(this).children('.icon_arrow_down')
    if($(image).attr('src') == '/plugin_assets/stalactite/images/circle_arrow_down.png'){
      $(image).attr('src', '/plugin_assets/stalactite/images/circle_arrow_top.png')
    } else{
      $(image).attr('src', '/plugin_assets/stalactite/images/circle_arrow_down.png')
    }
    $(this).parent().next('.day_results').toggle()
  })

  $('.users_list_link').click(function(e){
    e.preventDefault()
    image = $(this).children('.icon_arrow_down')
    if($(image).attr('src') == '/plugin_assets/stalactite/images/circle_arrow_down.png'){
      $(image).attr('src', '/plugin_assets/stalactite/images/circle_arrow_top.png')
    } else{
      $(image).attr('src', '/plugin_assets/stalactite/images/circle_arrow_down.png')
    }
    $(this).parent().next().toggle()
  })

  $('#search_time_type').change(function(){
    select_search_type()
  })

  select_search_type = function(){
    if($('#search_time_type option:selected').val() == 'idle_time'){
      $('.specified_period_p').hide()
      $('#search_specified_from, #search_specified_by').val('')
      $('.idle_time_p').show()
    } else if ($('#search_time_type option:selected').val() == 'specified_period'){
      $('.specified_period_p').show()
      $('#time_value').val('')
      $('.idle_time_p').hide()
    }
  }

  select_search_type()

  rendering_calendar = function(){
    time_control = {}
    $.each(_.range(10), function(){
      time_control[this] = []
    })
    indent_top = 0
    indent_left = 0
    continues_to = 0
    $.each($('.calendar_day_issue'), function(){
      calendar_day = $(this).parents('.calendar_day_hour_block').first()
      issue_start_hour = parseInt($(calendar_day).children('.day_hour').first().attr('attr_time'))
      issue_finished_hour = parseInt($(this).attr('finished_hour'))
      i = 0
      if(isNaN(issue_start_hour) != true){
        while(time_control[i].indexOf(issue_start_hour) != -1){
          i += 1
        }
        time_control[i] = _.range(issue_start_hour, issue_finished_hour)
        $(this).css('margin', (i * 30) + 'px 0px 0px ' + (i * 70) + 'px')
      }else{
        i = $('.calendar_day_issue').index(this)
        console.log(i)
        $(this).css('margin', (i * 30) + 'px 0px 0px ' + (i * 70) + 'px')
      }

      $(calendar_day).css('height', parseInt($(calendar_day).find('.calendar_day_issue').last().css('margin-top')) + 30)

      offset_start = $(calendar_day).offset()
      offset_end = $('.day_hour[attr_time="' + $(this).attr('finished_hour') + '"]').first().offset()

      if(offset_end != undefined){
        new_height = offset_end.top - offset_start.top - parseInt($(this).css('margin-top'))
        margin_top = $(this).css('margin-top')
        $(this).css('height', new_height)
      }


      continues_to = $(this).attr('finished_hour')

    })
     $.each($('.calendar_day_issue'), function(){

      calendar_day = $(this).parents('.calendar_day_hour_block').first()

      offset_start = $(calendar_day).offset()
      offset_end = $('.day_hour[attr_time="' + $(this).attr('finished_hour') + '"]').first().offset()

      if(offset_end != undefined){
        new_height = offset_end.top - offset_start.top - parseInt($(this).css('margin-top')) - 10
        margin_top = $(this).css('margin-top')
        $(this).css('height', new_height)
      }
    })
  }

  $('.calendar_day_issue').hover(
    function(){ $(this).find('.description_field').show() },
    function(){ $(this).find('.description_field').hide()  }
  )

  jQuery(document).ready(function() {
    if($('.calendar_day_hour_block').length > 0){
      rendering_calendar()
    }
  });

  $(window).resize(function(){
    rendering_calendar()
  })

})
