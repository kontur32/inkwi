module namespace report = 'content/reports/report-statistic1';

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
  return
      map{
        'отчет' : report:tables( $params, $начальнаяДата, $конечнаяДата ),
        'начальнаяДата' : $начальнаяДата,
        'конечнаяДата' : $конечнаяДата
      }
};

declare function report:tables( $params, $начальнаяДата, $конечнаяДата ){
  let $результат := 
  let $сотрудники := ( "Иванова Е.В.", "Кольчугина Н.В.", "Кулаков К.В." )
  for $i in $сотрудники
  let $путь := 
    replace(
      '/УНОИ/Кафедры/Управление образованием/Сотрудники/%1/Календарь.xlsx',
      '%1', $i
    )
  let $file := $params?_data?getFile( $путь, '.' )
  return
    report:table( $file, $i, $начальнаяДата, $конечнаяДата )/tr
 
  return 
    <table class = "table">
      <tr class = "text-center">
        <th>Категория</th>
        <th>Количество</th>
        <th>Трудоемкость (час.)</th>
      </tr>
      { $результат }
    </table>
    
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
    let $a := replace( xs:string( $j/cell[  @label = "Длительность" ]/text() ), '30', '50' )
    where $a
    return
      $a
  return
    <tr>
      <td>{ $категория }</td>
      <td class = "text-center">{ count( $i ) }</td>
      <td class = "text-center">{ sum( $i/cell[  @label = "Длительность" ]/text() )  }</td>
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