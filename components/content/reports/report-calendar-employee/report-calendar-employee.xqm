module namespace report = 'content/reports/report-calendar-employee';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report:main( $params ){
  let $текущаяДата := 
     substring-before(
       xs:string( current-date() ), '+'
     )
   
  let $начальнаяДата := 
     if( request:parameter( 'начальнаяДата' ) )
     then( request:parameter( 'начальнаяДата' ) )
     else( '2021-03-01' )
   
  let $конечнаяДата := 
     if( request:parameter( 'конечнаяДата' ) )
     then( request:parameter( 'конечнаяДата' ) )
     else( '2021-03-20' )
  
  let $текущаяКафедра :=
    if( request:parameter( 'кафедра' ) )
    then( request:parameter( 'кафедра' ) )
    else( 'Управление образованием' )
  
  let $p := 
    map:merge(
      (
        $params,
        map{
          'начальнаяДата' : $начальнаяДата,
          'конечнаяДата' : $конечнаяДата,
          'кафедра' : $текущаяКафедра
        }
      )
    )
    
  return
      map{
        'кафедра' : $текущаяКафедра,
        'отчет' : report:tables( $p, $начальнаяДата, $конечнаяДата ),
        'кафедры' : report:кафедра( $текущаяКафедра ),
        'начальнаяДата' : $начальнаяДата,
        'конечнаяДата' : $конечнаяДата
      }
};

declare function report:tables( $params, $начальнаяДата, $конечнаяДата ){
  let $календари :=
    $params?_tpl( 'api/list-calendar', $params )/data/мероприятия/row
  
  let $сотрудники := 
    distinct-values( $календари/cell[ @label = 'Сотрудник' ]/text() ) 
  
  let $строки := 
    for $i in $календари
    let $дата := $i/cell[ @label = 'Дата' ]/text()
    order by $дата
    group by $дата
    return
      <tr>
        <td>{
          replace( xs:string( $дата ), '(\d{4})-(\d{2})-(\d{2})',  '$3.$2.$1' )
        }</td>
        {
          for $j in $сотрудники
          let $мероприятия := $i[ cell[ @label = 'Сотрудник' ]/text() = $j ]
          let $записи :=
            for $k in $мероприятия
            return
              1
          return 
            <td>{
              string-join( $мероприятия/cell[ @label = 'Название мероприятия']/text(), ' | ' )
            }</td>
        }
      </tr>
  return
    <table class = "table table-bordered">
      <tr class = "thead-default text-center">
        <th width="10%">Дата</th>
        {
          for $i in $сотрудники
          return
            <th width = '30%'>{ $i }</th>
        }
      </tr>
      { $строки }
    </table>
};

declare function report:кафедра( $текущаяКафедра ){
  let $кафедры :=
     (
      [ 'Управление образованием', ( "Иванова Е.В.", "Кольчугина Н.В.", "Кулаков К.В." ) ],
      [ 'Образовательных дисциплин', ( "Шепелев М.В.", "Никольская А.В.", "Омельченко И.Н.", "Тихонова Н.М.", "Туртин Д.В.", "Маилян Н.Р.",  "Аверьянова И.Ю.", "Корнева Л.М.", "Прохорова О.А.") ],   
      [ '1. Учебно-методический отдел', ( "Соколова Л.В.", "Абрамова М.Г.", "Вайтайтене А.А." ) ],
      [ 'Кафедра дошкольного и инклюзивного образования', ( "Киселева Н.В.", "Осипова О.В.", "Шакирова Е.В." ) ],
      
      [ 'Кафедра педагогики и психологии', ( "Веренина С.А.", "Исаева Н.М.", "Полывянная М.Т.", "Химилова Т.Н." ) ],
      [ '0 Ресурсы университета', ( "206 аудитория", "Актовый зал" ) ]
    )
      
  return
    <select name = 'кафедра'>{
      for $i in $кафедры?1
      order by $i
      return
        <option value = '{ $i }'>{ $i }</option>
        update insert node $i = $текущаяКафедра ?? attribute {'selected'} {'yes'} !! () into .
    }</select>
};