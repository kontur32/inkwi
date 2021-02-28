module namespace reports = 'school/reports';

declare function reports:main( $params ){
  
  let $страница := 
    switch ( $params?отчет )
    case "учителя-кпк"
      return
        $params?_tpl( 'school/reports/teachers', map{} )
    case "учителя-категории"
      return
        $params?_tpl( 'school/reports/teachers-category', map{} )
    case "календарный-план"
      return
        $params?_tpl( 'content/reports/report-plan-kpk', map{} )
    default
      return 
        $params?_tpl( 'content/reports/report-plan-kpk', map{} )
  
  return
    map{
      'отчет' : $страница
    }
};