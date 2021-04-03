module namespace data = "/unoi/api/v01/data/reports/kurses/kolichestvo.kafedra";

import module namespace funct="funct" at "../../functions/functions.xqm"; 

declare 
  %rest:GET
  %output:method('json')
  %rest:path( "/unoi/api/v01/data/reports/kurses/{ $mode }.kafedra" )
function data:main( $mode ){
   let $data := 
    funct:tpl2( 'api/list-courses', map{} )/data

  let $курсы :=
    for $i in $data/спискиКурсов/file
    let $КПК := $i//row
    
    let $результат :=
      if( $mode = 'revenue' )
      then(
        sum(
          for-each(
            $КПК,
            function( $var ){ 
              $var/cell[ @label = 'Завершили' ]/text() * 
              $var/cell[ @label = 'Стоимость обучения' ]/text() 
            }
          )
        )
      )
      else( count( $КПК ) )
    
    let $названиеКафедры := $КПК[ 1 ]/cell[ @label = 'Кафедра' ]/text()
    
    return
        <_ type = "array">
         <_>{ $названиеКафедры }</_>
         <_ type = 'number'>{ $результат }</_>
       </_>
 
 return
   <json type = "array">
       <_ type = "array">
         <_>Tasks</_>
         <_>Структура курсов</_>
       </_>
       { $курсы }
   </json>
};