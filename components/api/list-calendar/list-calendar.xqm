module namespace list-courses = "api/list-calendar";

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function list-courses:main( $params as map(*) ){
  map{
    'списокКурсов' : list-courses:курсы( $params ) 
  }
};

declare function list-courses:курсы( $params ){
  let $начальнаяДата := $params?начальнаяДата
  let $конечнаяДата :=  $params?конечнаяДата
  let $сотрудники := ( "Иванова Е.В.", "Кольчугина Н.В.", "Кулаков К.В." )
  
  let $календари :=
    for $i in $сотрудники
    let $путь := 
      replace(
        '/УНОИ/Кафедры/Управление образованием/Сотрудники/%1/Календарь.xlsx',
        '%1',  substring-before( $i, ' ' )
      )  
    let $file := $params?_data?getFile( $путь,  '.' )
    let $c := 
      for $ii in $file//table[ @label="Ежедневник" ]/row
      let $дата := dateTime:dateParse( $ii/cell[ @label = 'Дата' ]/text() )
      where $дата >= xs:date( $начальнаяДата ) and $дата <= xs:date( $конечнаяДата )
      where $ii/cell[ @label = 'Название мероприятия' ]/text()
      return
        $ii
          update { replace value of node ./cell[ @label = 'Дата' ] with  $дата }
          update { insert node <cell label = 'Сотрудник'>{ $i }</cell> into . }
    return
      $c
  return
    <data>
      <мероприятия>{ $календари }</мероприятия>
    </data>  
};