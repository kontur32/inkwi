module namespace list-courses = "api/list-courses";

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function list-courses:main( $params as map(*) ){
  let $data := 
     $params?_data?getFile( '/УНОИ/Кафедры/Сводная.xlsx',  '.' )
  return
    map{
      'списокКурсов' :
        <data>
          <спискиКурсов>{ list-courses:курсы( $data, $params )  }</спискиКурсов>
          <сводная>{ $data }</сводная>
        </data>
         
    }
};

declare function list-courses:курсы( $data, $params ){
  let $кафедры := $data//table[ @label = 'Кафедры' ]
  let $списокКурсов :=
    for $i in $кафедры/row  
    let $названиеКафедры :=
      $i/cell[ @label = 'Название кафедры' ]/text()
    let $курсыКафедры :=
      $params?_data?getFile(
        '/УНОИ/Кафедры/' || $названиеКафедры || '/Курсовые мероприятия кафедры.xlsx',  '.'
      ) 
    let $кафедра := 
      <cell label = 'Кафедра'>{ $i/cell[ @label = 'Название кафедры' ]/text() }</cell>
    return
      <file>
        <table>
          {
            for $j in $курсыКафедры//row
            where 
              if( map:contains( $params, '_filter' ) and map:contains( $params, 'courseID' )  )
              then( $params?_filter( $j, $params?courseID ) )
              else( true() )
            return
              $j update insert node $кафедра into .
          }
        </table>
      </file>
  
  return
    $списокКурсов
};