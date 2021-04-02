module namespace reports = 'content/reports';

declare function reports:main( $params ){
  let $страница := 
    switch ( $params?страница )
    case "сводная"
      return
        <span>Здесь будет сводная таблица по всем кафедрам</span>
      (:
        fetch:xml( 'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/7d9b8696-f1be-4abb-9952-2b1947f8193c' )//div[ @id = 'content' ]
      :)
        
    case "api-курсы" (: временно для отладки :)
      return
        $params?_tpl( 'api/list-courses', $params )
    
    case "отчет-статистика-занятость"
      return
        $params?_tpl( 'content/reports/report-statistic1', map{} )
    case "отчет-курсы"
      return
        $params?_tpl( 'content/reports/report-courses', map{} )
    case "отчет-календарь"
      return
        $params?_tpl( 'content/reports/report-calendar', map{} )
    case "отчет-календарь-сотрудники"
      return
        $params?_tpl( 'content/reports/report-calendar-employee', map{} )
    case "календарный-план"
      return
        $params?_tpl( 'content/reports/report-plan-kpk', map{} )
    
    default 
      return
        fetch:xml( 'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/031fefd3-e1b6-4ce6-885b-601429101680' )//div[ @id = 'content' ]
  
  return
    map{
      'параметры' : $params?query-params?кафедра,
      'отчет' : $страница
    }
};