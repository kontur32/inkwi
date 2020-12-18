module namespace report = 'content/reports/report-courses';

declare function report:main( $params ){
    map{ 'отчет' : report:table() }
};

declare function report:table(){
  let $data := 
    fetch:xml( 'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/c48c07c3-a998-47bf-8e33-4d6be40bf4a7' )
  
  let $виды := $data//table[ @label = 'ДПО' ]
  let $уровни := $data//table[ @label = 'Уровни' ]
  let $кафедры := $data//table[ @label = 'Кафедры' ]
  let $курсы :=
    for $i in $кафедры/row
    let $path := $i/cell[ @label = 'График КПК' ]/text()
    let $КПК := fetch:xml( $path )//row
    return
      $КПК update insert node <cell label = 'Кафедра'>{ $i/cell[ @label = 'Название кафедры' ]/text() }</cell> into .

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
    <table class="table table-bordered">
      <tr align="center">
        <th>Категория</th>
        <th>Всего</th>
        {
          for $i in $кафедры
          return
            <th>{ $i }</th>
        }
      </tr>
      { $строки }
      <tr align="center">
        <th align="left" >Итого:</th>
        <th>{ count( $курсы ) }</th>
        { $всегоПоКафедрам }
      </tr>
    </table>
};