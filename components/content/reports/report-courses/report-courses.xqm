module namespace report = 'content/reports/report-courses';

declare function report:main( $params ){
    map{ 'отчет' : report:table( $params ) }
};

declare function report:table( $params ){
  let $d:= $params?_tpl( 'api/list-courses', $params )
  
  let $курсы := $d//спискиКурсов//row

  let $кафедры := distinct-values( $курсы/cell[ @label = 'Кафедра' ]/text() )
  let $уровни := distinct-values( $курсы/cell[ @label = 'Уровень' ]/text() )
  
  let $строки :=  
    for $i in $уровни
    let $r := $курсы[ cell[ @label = 'Уровень']/text() = $i ]
    let $всего := count( $r )
    order by $всего descending
    
        
    return
      <tr align="center">
        <td align="left">{ $i }</td>
        <td>
          { $всего }<br/>
          { count( $r[ cell[ @label = 'Завершили' ]/text() ] ) }<br/>
          { sum( $r/cell[ @label = 'Завершили' ]/text() ) }<br/>
          { sum( for-each( $r, function( $var ){ $var/cell[ @label = 'Завершили' ]/text() * $var/cell[ @label = 'Стоимость обучения' ]/text() } ) ) }
        </td>
      {
        for $j in  $кафедры
        let $rr := $r[ cell[ @label = 'Кафедра']/text() = $j ]
        return
           <td>
             { count( $rr ) }<br/>
             { count( $rr[ cell[ @label = 'Завершили' ]/text() ] ) }<br/>
             { sum( $rr/cell[ @label = 'Завершили' ]/text() ) }<br/>
             { sum( for-each( $rr, function( $var ){ $var/cell[ @label = 'Завершили' ]/text() * $var/cell[ @label = 'Стоимость обучения' ]/text() } ) ) }
           </td>
      }</tr>
  let $всегоПоКафедрам := 
    for $i in  $кафедры
    let $количество := $курсы[ cell[ @label = 'Кафедра']/text() = $i ]
    return
      <th>
        { count( $количество ) }<br/>
        { count( $количество[ cell[ @label = 'Завершили' ]/text() ] ) }<br/>
        { sum( $количество/cell[ @label = 'Завершили' ]/text() ) }<br/>
        { sum( for-each( $количество, function( $var ){ $var/cell[ @label = 'Завершили' ]/text() * $var/cell[ @label = 'Стоимость обучения' ]/text() } ) ) }
      </th>
  
  let $всего :=
    <th>
      { count( $курсы ) }<br/>
      { count( $курсы[ cell[ @label = 'Завершили' ]/text() ] ) }<br/>
      { sum( $курсы/cell[ @label = 'Завершили' ]/text() ) }<br/>
      { sum( for-each( $курсы, function( $var ){ $var/cell[ @label = 'Завершили' ]/text() * $var/cell[ @label = 'Стоимость обучения' ]/text() } ) ) }
    </th>
  
  return
    <table class="table table-bordered table-striped shadow ">
      <thead>
        <tr align="center">
          <th>Категория</th>
          <th>Всего</th>
          {
            for $i in $кафедры
            return
              <th>{ $i }</th>
          }
        </tr>
      </thead>
      <tbody>
        <tr align="center">
          <th class="text-left" >
            Итого план:<br/>
            Проведено курсов<br/>
            Студентов<br/>
            Выручка
          </th>
          { $всего }
          { $всегоПоКафедрам }
        </tr>
        { $строки }
      </tbody>
    </table>
};