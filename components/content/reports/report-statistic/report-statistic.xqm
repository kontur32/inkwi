module namespace report = 'content/reports/report-statistic';

import module namespace functx = "http://www.functx.com";
import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report:main( $params ){
  let $текущаяДата := 
     substring-before(
       xs:string( current-date() ), '+'
     )
   
  let $начальнаяДата := 
     if( request:parameter( 'начальнаяДата' ) )
     then( request:parameter( 'начальнаяДата' ) )
     else( $текущаяДата )
   
  let $конечнаяДата := 
     if( request:parameter( 'конечнаяДата' ) )
     then( request:parameter( 'конечнаяДата' ) )
     else( $текущаяДата )
     
  let $текущаяКафедра :=
    if( request:parameter( 'кафедра' ) )
    then( request:parameter( 'кафедра' ) )
    else( 'Управление образованием' )
  let $параметры := 
    map:merge(
      (
        map{
          'начальнаяДата' : $начальнаяДата,
          'конечнаяДата' : $конечнаяДата,
          'кафедра' : $текущаяКафедра
        }
      )
    )
  return
      map{
        'отчет' : report:tables( $params, $параметры ),
        'кафедры' : report:кафедра( $текущаяКафедра ),
        'начальнаяДата' : $начальнаяДата,
        'конечнаяДата' : $конечнаяДата
      }
};

declare function report:tables( $params, $параметры ){
  let $сотрудники := report:сотрудникиКафедры( $параметры?кафедра )
  let $результат := 
    for $i in $сотрудники
    let $путь := 
      functx:replace-multi(
        '/УНОИ/Кафедры/%1/Сотрудники/%2/Календарь.xlsx',
        ( '%1', '%2' ),  ( $параметры?кафедра, substring-before( $i, ' ' ) )
      )  
    let $file := $params?_data?getFile( $путь, '.' )
    return
      report:table( $file, $i, $параметры?начальнаяДата, $параметры?конечнаяДата )/tr
   
   let $таблица :=
      <table class = "table">
        <tr class = "text-center">
          <th>Категория</th>
          <th>Количество</th>
          <th>Трудоемкость (час.)</th>
        </tr>
        { $результат }
      </table>
   return
     $таблица
      
};

declare function report:table( $file, $сотрудник, $начальнаяДата, $конечнаяДата ){    
let $строки := 
  for $i in $file//table[ @label = "Ежедневник" ]/row
  where $i/cell[ @label = "Название мероприятия" ]/text()
  where
    dateTime:dateParse( $i/cell[ @label = "Дата" ]/text() ) >= xs:date( $начальнаяДата ) and
    dateTime:dateParse( $i/cell[ @label = "Дата" ]/text() ) <= xs:date( $конечнаяДата )
  return
    $i
let $результат  :=
 for $i in $строки
 let $категория := 
    if( $i/cell[ @label = "Категория мероприятия" ]/text() )
    then( $i/cell[ @label = "Категория мероприятия" ]/text() )
    else( 'Без категории' )
  
  group by $категория
  
  let $длительность :=
    for $j in $i
    let $a:= 
      try{ $j/cell[  @label = "Длительность" ]/number() * 24 }
      catch*{ 0 }
    where $a or true()
    return
      $a
  
  return
    <tr>
      <td>{ $категория }</td>
      <td class = "text-center">{ count( $i ) }</td>
      <td class = "text-center">{ round( sum( $длительность ) )  }</td>
    </tr>

return
    <tbody>
      <tr>
        <th colspan = "3">{ $сотрудник }</th>
      </tr>
      { $результат }
      <tr>
          <td>Всего</td>
          <th class = "text-center">{ count( $строки ) }</th>
          <th class = "text-center">{ sum( $результат/td[ 3 ]/text() ) }</th>
      </tr>
      <tr>
        <td colspan = "3"></td>
      </tr>
    </tbody>
  
};

declare function report:кафедра( $текущаяКафедра ){
  let $кафедры :=
      (
        [ 'Управление образованием', ( "Иванова Е.В.", "Кольчугина Н.В.", "Кулаков К.В." ) ]
        ,
        [ 'Естественно-научных дисциплин', ( "Никольская А.В.", "Омельченко И.Н.", "Тихонова Н.М.", "Туртин Д.В.", "Маилян Н.Р." ) ],
        [ 'Кафедра гуманитарных дисциплин', ( "Аверьянова И.Ю.", "Корнева Л.М.", "Прохорова О.А." ) ],     
        [ '1. Учебно-методический отдел', ( "Соколова Л.В.", "Абрамова М.Г.", "Вайтайтене А.А." ) ],
        [ 'Кафедра дошкольного и инклюзивного образования', ( "Киселева Н.В.", "Опарина Н.В.", "Осипова О.В.", "Шакирова Е.В.", "Тихомирова Е.В." ) ],
        
        [ 'Кафедра педагогики и психологии', ( "Веренина С.А.", "Исаева Н.М.", "Полывянная М.Т.", "Химилова Т.Н." ) ],
        [ '0 Ресурсы университета', ( "206 аудитория" ) ]
      )
      
  return
    <select name = 'кафедра'>{
      for $i in $кафедры?1
      order by $i
      return
        <option value = '{ $i }'>{ $i }</option>
        update insert node $i = $текущаяКафедра ?? attribute {'selected'} {'yes'} !! () into .
    }</select>
};

declare function report:сотрудникиКафедры( $текущаяКафедра ){
  let $кафедры :=
      (
        [ 'Управление образованием', ( "Иванова Е.В.", "Кольчугина Н.В.", "Кулаков К.В." ) ]
        ,
        [ 'Естественно-научных дисциплин', ( "Никольская А.В.", "Омельченко И.Н.", "Тихонова Н.М.", "Туртин Д.В.", "Маилян Н.Р." ) ],
        [ 'Кафедра гуманитарных дисциплин', ( "Аверьянова И.Ю.", "Корнева Л.М.", "Прохорова О.А." ) ],     
        [ '1. Учебно-методический отдел', ( "Соколова Л.В.", "Абрамова М.Г.", "Вайтайтене А.А." ) ],
        [ 'Кафедра дошкольного и инклюзивного образования', ( "Киселева Н.В.", "Опарина Н.В.", "Осипова О.В.", "Шакирова Е.В.", "Тихомирова Е.В." ) ],
        
        [ 'Кафедра педагогики и психологии', ( "Веренина С.А.", "Исаева Н.М.", "Полывянная М.Т.", "Химилова Т.Н." ) ],
        [ '0 Ресурсы университета', ( "206 аудитория" ) ]
      )
   return
     $кафедры[?1=$текущаяКафедра]?2
};