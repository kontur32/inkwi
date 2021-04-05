module namespace list-courses = "api/list-calendar";

import module namespace functx = "http://www.functx.com";
import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function list-courses:main( $params as map(*) ){
  map{
    'списокКурсов' : list-courses:курсы( $params ) 
  }
};

declare function list-courses:курсы( $params ){
  let $начальнаяДата := $params?начальнаяДата
  let $конечнаяДата :=  $params?конечнаяДата
  let $кафедры :=
    (
      [ 'Управление образованием', ( "Иванова Е.В.", "Кольчугина Н.В.", "Кулаков К.В." ) ]
      ,
      [ 'Естественно-научных дисциплин', ( "Никольская А.В.", "Омельченко И.Н.", "Тихонова Н.М.", "Туртин Д.В." ) ],
      [ 'Кафедра гуманитарных дисциплин', ( "Аверьянова И.Ю.", "Корнева Л.М.", "Прохорова О.А." ) ],
      [ '1. Учебно-методический отдел', ( "Соколова Л.В.", "Абрамова М.Г.", "Вайтайтене А.А." ) ],
      [ '3. Региональный центр инновационных технологий в образовании (РЦИТО)', ( "Грудочкина И.Л.", "Гвоздева М.Ю.", "Дегтярева С.А.", "Бригаднов М.К." ) ]
    )
  let $все :=
  for $кафедра in $кафедры
  let $календари :=
    for $i in $кафедра?2
    let $путь := 
      functx:replace-multi(
        '/УНОИ/Кафедры/%1/Сотрудники/%2/Календарь.xlsx',
        ( '%1', '%2' ),  ( $кафедра?1, substring-before( $i, ' ' ) )
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
    
      <мероприятия>{ $календари }</мероприятия>
return
  <data>{ $все }</data>    
};