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
        <td>{ $всего }</td>
      {
        for $j in  $кафедры
        let $rr := $r[ cell[ @label = 'Кафедра']/text() = $j ]
        return
           <td>{ count( $rr ) }</td>
      }</tr>
  let $всегоПоКафедрам := 
    for $i in  $кафедры
    let $количество := $курсы[ cell[ @label = 'Кафедра']/text() = $i ]
    return
      <th >{ count( $количество ) }</th>
  
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
        { $строки }
        <tr align="center">
          <th align="left" >Итого:</th>
          <th>{ count( $курсы ) }</th>
          { $всегоПоКафедрам }
        </tr>
      </tbody>
    </table>
};