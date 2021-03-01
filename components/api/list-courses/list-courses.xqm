module namespace list-courses = "api/list-courses";

declare function list-courses:main( $params as map(*) ){
  map{
    'списокКурсов' :
       list-courses:курсы( $params ) 
  }
};

declare function list-courses:курсы( $params ){
   let $data := 
     $params?_data?getFile( '/УНОИ/Кафедры/Сводная.xlsx',  '.' )
  
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
            return
              $j update insert node $кафедра into .
          }
        </table>
      </file>
  
  return
    <data>
      <спискиКурсов>{ $списокКурсов }</спискиКурсов>
      <сводная>{ $data }</сводная>
    </data>
};