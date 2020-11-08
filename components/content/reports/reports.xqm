module namespace reports = 'content/reports';

declare function reports:main( $params ){
  let $адресЗапросаСтраницы := 
    switch ( $params?страница )
    case "сводная"
      return
        'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/7d9b8696-f1be-4abb-9952-2b1947f8193c'
    case "календарный-план"
      return
        'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/031fefd3-e1b6-4ce6-885b-601429101680'
    default 
      return
        'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/031fefd3-e1b6-4ce6-885b-601429101680'
  
  let $страница :=
    fetch:xml( $адресЗапросаСтраницы )
  
  return
    map{
      'отчет' : $страница//div[ @id = 'content' ]
    }
};