module namespace report = 'content/reports/report-calendar-employee';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report:main( $params ){
  let $текущаяДата := 
     substring-before(
       xs:string( current-date() ), '+'
     )
   
  let $начальнаяДата := 
     if( request:parameter( 'начальнаяДата' ) )
     then( request:parameter( 'начальнаяДата' ) )
     else( '2021-03-01' )
   
  let $конечнаяДата := 
     if( request:parameter( 'конечнаяДата' ) )
     then( request:parameter( 'конечнаяДата' ) )
     else( '2021-03-20' )
  let $p := 
    map:merge(
      (
        $params,
        map{
          'начальнаяДата' : $начальнаяДата,
          'конечнаяДата' : $конечнаяДата
        }
      )
    )
  return
      map{
        'отчет' : report:tables( $p, $начальнаяДата, $конечнаяДата ),
        'начальнаяДата' : $начальнаяДата,
        'конечнаяДата' : $конечнаяДата
      }
};

declare function report:tables( $params, $начальнаяДата, $конечнаяДата ){
  let $календари :=
    $params?_tpl( 'api/list-calendar', $params )/data/мероприятия/row
  let $сотрудники := 
    distinct-values( $календари/cell[ @label = 'Сотрудник' ]/text() ) 
  let $строки := 
    for $i in $календари
    let $дата := $i/cell[ @label = 'Дата' ]/text()
    order by $дата
    group by $дата
    return
      <tr>
        <td>{
          replace( xs:string( $дата ), '(\d{4})-(\d{2})-(\d{2})',  '$3.$2.$1' )
        }</td>
        {
          for $j in $сотрудники
          let $мероприятия := $i[ cell[ @label = 'Сотрудник' ]/text() = $j ]
          return 
            <td>{
              string-join( $мероприятия/cell[ @label = 'Название мероприятия']/text(), ' | ' )
            }</td>
        }
      </tr>
  return
    <table class = "table table-bordered">
      <tr class = "thead-default text-center">
        <th width="10%">Дата</th>
        {
          for $i in $сотрудники
          return
            <th width = '30%'>{ $i }</th>
        }
      </tr>
      { $строки }
    </table>
};