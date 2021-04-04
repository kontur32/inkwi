module namespace report = 'content/reports/report-calendar';

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
  let $сотрудники := ( "Иванова Е.В.", "Кольчугина Н.В.", "Кулаков К.В." )
  for $i in $сотрудники
  let $путь := 
    replace(
      '/УНОИ/Кафедры/Управление образованием/Сотрудники/%1/Календарь.xlsx',
      '%1', substring-before( $i, ' ' )
    )
  let $file := $params?_data?getFile( $путь, '.' )
  return
    report:table( $file, $i, $начальнаяДата, $конечнаяДата )
};

declare function report:table( $file, $сотрудник, $начальнаяДата, $конечнаяДата ){    
let $строки := 
  for $i in $file//table[ @label = "Ежедневник" ]/row
  let $дата := dateTime:dateParse( $i/cell[ @label = 'Дата' ]/text() )
  where $дата >= xs:date( $начальнаяДата ) and $дата <=  xs:date( $конечнаяДата )
  where $i/cell[ @label = "Время начала" ]/text() or $i/cell[ @label = "Длительность" ]/text()
  group by $дата
  return
    for $j in $i
    count $c
    return
    <tr>{
      let $датаСтрока :=
          replace( xs:string( $дата ),
            '(\d{4})-(\d{2})-(\d{2})',
            '$3.$2.$1'
          )
      let $продолжительность :=
        try{ round( $j/cell[  @label = "Длительность" ]/number() * 24, 1 ) }
        catch*{ 0 }
      
      let $начало :=
          try{ 
            let $a := $j/cell[  @label = "Время начала" ]/number() * 24
            let $часы := floor( $a )
            let $минуты := ( $a - $часы ) * 60
            return
               replace( $часы || ':' || $минуты , ':([0]{1})$', ':$10' )
          }
          catch*{ '-' }
      return
        (
          if( $c = 1 )
          then(
            <td rowspan = "{ count( $i ) }">
              { $датаСтрока }
            </td>
          )
          else(),
          <td>
            { $j/cell[ @label = 'Название мероприятия' ]/text() }<br/>
            (начало: { $начало }, продолжительность: { $продолжительность } час., форма: { $j/cell[ @label = 'Форма']/text() }, категория: { $j/cell[ @label = 'Категория мероприятия' ]/text() }, инициатор: { $j/cell[ @label = 'Инициатор' ]/text() })
          </td>,
          <td>{
             $j/cell[ @label = 'Результат']/text()
          }</td>
        )
        
    }</tr>
    
return
  <div>
    <h4>{ $сотрудник }</h4>
    <table class = "table">
      <tr>
        <td>Дата</td>
        <td>Мероприятие</td>
        <td>Результат</td>
      </tr>
      { $строки }
    </table>
  </div>
  
};