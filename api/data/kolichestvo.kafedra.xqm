module namespace data = "/unoi/api/v01/data/reports/kurses/kolichestvo.kafedra";

declare 
  %rest:GET
  %output:method('json')
  %rest:path( "/unoi/api/v01/data/reports/kurses/kolichestvo.kafedra" )
function data:main(){
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
        <_ type = "array">
         <_>{ $i/cell[ @label = 'Название кафедры' ]/text() }</_>
         <_ type = 'number'>{ count( $КПК ) }</_>
       </_>
 return
   <json type = "array">
       <_ type = "array">
         <_>Tasks</_>
         <_ >Структура курсов</_>
       </_>
       { $курсы }
    
   </json>
};