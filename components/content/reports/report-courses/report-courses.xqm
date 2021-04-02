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
    order by count( $r ) descending
    return
      <tr align="center">
        <td align="left">{ $i }</td>
        <td>
          { report:данные( $r ) }
        </td>
      {
        for $j in  $кафедры
        let $rr := $r[ cell[ @label = 'Кафедра']/text() = $j ]
        return
           <td>
             { report:данные( $rr ) }
           </td>
      }</tr>
  let $всегоПоКафедрам := 
    for $i in  $кафедры
    let $количество := $курсы[ cell[ @label = 'Кафедра']/text() = $i ]
    return
      <th>
        { report:данные( $количество ) }
      </th>
  
  let $всего :=
    <th>
      { report:данные( $курсы ) }
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

declare function report:данные( $курсы ){
  let $стоимостьПоКурсам :=
    sum(
      for-each(
        $курсы,
        function( $var ){ 
          $var/cell[ @label = 'Завершили' ]/text() * 
          $var/cell[ @label = 'Стоимость обучения' ]/text() 
        }
      )
    )
  return
    <span>
      { count( $курсы ) }<br/>
      { count( $курсы[ cell[ @label = 'Завершили' ]/text() ] ) }<br/>
      { sum( $курсы/cell[ @label = 'Завершили' ]/text() ) }<br/>
      { replace( xs:string( $стоимостьПоКурсам ), '(\d{3})$', '.$1'  ) }
    </span>
  
};