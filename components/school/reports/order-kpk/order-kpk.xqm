module namespace report = 'school/reports/order-kpk';

declare function report:main( $params ){
    map{
      'учителя' : report:учителя( $params ),
      'курсы' : report:курсы()
    }
};

declare
  %private
function report:учителя( $params ){
  <lo>
      {
        for $i in $params?query-params?учитель
        return  
            <div class = "row my-2">
              <div class = "col-9">{ $i }</div> 
              <div class = "col-2"><input form = "teacher" type = "radio" name = "radio" class = "form-check-input radio"/></div>
              <div class = "col-12 mb-2"><input form = "teacher" type = "text" name = "выбранныйКурс" class="form-control выбранныйКурс"  readonly = 'yes' placeholder = "курс ПК" /></div>
            </div>
           
      }
   </lo>
};

declare
  %private
function report:курсы(){
  let $data := 
    fetch:xml( 'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/c48c07c3-a998-47bf-8e33-4d6be40bf4a7' )
  
  let $виды := $data//table[ @label = 'ДПО' ]
  let $уровни := $data//table[ @label = 'Уровни' ]
  let $кафедры := $data//table[ @label = 'Кафедры' ]
  
  for $i in $кафедры/row
  let $path := $i/cell[ @label = 'График КПК' ]/text()
  let $КПК := fetch:xml( $path )//row[ cell[ @label = 'Объем' ]/text() = ( '72', '36' ) ]
  for $j in $КПК
  order by $j/cell[ @label = 'Объем' ]/text()
  return
        <div class = "row курс">
          <div class = "col-md-1">{ $j/cell[ @label = "Объем" ]/text() }</div>
          <div class = "col-md-8 название">{ $j/cell[ @label = "Название ДПП" ]/text() }</div>
          <div class = "col-md-3">{ $j/cell[ @label = "Дни очного обучения" ]/text() }</div>
        </div> 
};