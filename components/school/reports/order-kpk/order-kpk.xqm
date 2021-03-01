module namespace report = 'school/reports/order-kpk';

declare function report:main( $params ){
    map{
      'учителя' : report:учителя( $params ),
      'курсы' : report:курсы( $params )
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
function report:курсы( $params ){

  let $data := 
     $params?_data?getFile( '/УНОИ/Кафедры/Сводная.xlsx',  '.' )
  let $кафедры := $data//table[ @label = 'Кафедры' ]
  
  for $i in $кафедры/row  
  let $названиеКафедры :=
    $i/cell[ @label = 'Название кафедры' ]/text()
  let $КПК :=
    $params?_data?getFile( '/УНОИ/Кафедры/' || $названиеКафедры || '/Курсовые мероприятия кафедры.xlsx',  '.' )
    //row[ cell[ @label = 'Объем' ]/text() = ( '36', '72' ) ]
  
  for $j in $КПК
  order by $j/cell[ @label = 'Объем' ]/text()
  return
        <div class = "row курс">
          <div class = "col-md-1">{ $j/cell[ @label = "Объем" ]/text() }</div>
          <div class = "col-md-8 название">{ $j/cell[ @label = "Название ДПП" ]/text() }</div>
          <div class = "col-md-3">{ $j/cell[ @label = "Дни очного обучения" ]/text() }</div>
        </div> 
};