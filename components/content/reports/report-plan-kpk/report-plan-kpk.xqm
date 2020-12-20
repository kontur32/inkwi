module namespace report = 'content/reports/report-plan-kpk';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report:main( $params ){
   let $data := 
    fetch:xml( 'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/c48c07c3-a998-47bf-8e33-4d6be40bf4a7' )
   return
    map{ 'отчет' : report:tables( $data, $params?_tpl ) }
};

declare function report:date( $var ){
  replace(
      xs:string(
        dateTime:dateParse( $var )
      ),
      '(\d{4})-(\d{2})-(\d{2})',
      '$3.$2.$1'
    ) 
};

declare function report:ifNotEmpty( $str, $var ){
    if( $var )
    then( ( $str, <div>{ $var }</div> ) )
    else()
  };

declare function report:table( $i ){
  <table class = "table table-bordered" width="100%">
        <thead>
          <tr class = 'text-center'>
            <th class = 'align-middle' width="20%">Категория слушателей</th>
            <th class = 'align-middle' width="40%">Название дополнительной профессиональной программы, аннотация</th>
            <th class = 'align-middle' width="10%">Объем программы, час</th>
            <th class = 'align-middle' width="10%">Сроки обучения, час.</th>
            <th class = 'align-middle' width="10%">Стоимость, рублей</th>
            <th class = 'align-middle' width="10%">Руководитель курсов</th>
          </tr>
        </thead>
        <tbody>
          {
          for $j in $i
          return
            <tr>
              <td>{ $j/cell[ @label = 'Целевая категория']/text() }</td>
              <td>
                <b><i>{ $j/cell[ @label = 'Название ДПП']/text() }</i></b><br/>
                {
                  report:ifNotEmpty(
                    <b>В программе:</b>,
                   $j/cell[ @label = 'В программе']/text()
                  )
                }
                {
                  report:ifNotEmpty(
                    <b>Результат обучения:</b>,
                    $j/cell[ @label = 'В результате обучения']/text()
                  )
                }
                {
                  report:ifNotEmpty(
                    <b>Итоговая аттестация:</b>,
                    $j/cell[ @label = 'Итоговая аттестация']/text()
                  )
                }
                {
                  (
                    <b>Кафедра:</b>,
                    <div>{ lower-case( $j/cell[ @label = 'Кафедра' ]/text() ) }</div>
                  )
                }
              </td>
              <td class = 'text-center'>{ $j/cell[ @label = 'Объем']/text() }</td>
              <td class = 'text-center'>
                { report:date( $j/cell[ @label = 'Начало КПК']/text() ) }-
                { report:date( $j/cell[ @label = 'Окончание КПК']/text() ) }
                {
                  report:ifNotEmpty(
                    <div>Очный этап:</div>,
                    $j/cell[ @label = 'Дни очного обучения']/text()
                  )
                }
              </td>
              <td class = 'text-center'>{ $j/cell[ @label = 'Стоимость обучения']/text() }</td>
              <td>{ $j/cell[ @label = 'Руководитель КПК']/text() }</td>
            </tr>
          }
        </tbody>
      </table>
};

declare function report:tables( $data, $tpl ){
  let $виды := $data//table[ @label = 'ДПО' ]
  let $уровни := $data//table[ @label = 'Уровни' ]
  let $кафедры := $data//table[ @label = 'Кафедры' ]
  let $курсы :=
    for $i in $кафедры/row
    let $path := $i/cell[ @label = 'График КПК' ]/text()
    let $КПК := fetch:xml( $path )//row
    return
      $КПК update insert node <cell label = 'Кафедра'>{ $i/cell[ @label = 'Название кафедры' ]/text() }</cell> into .
  
 return
    for $i in $курсы
    let $вид := 
      let $часов :=
        xs:integer( 
          let $ч := 
            if( $i/cell[ @label = 'Объем' ]/text() != '' )
            then( $i/cell[ @label = 'Объем' ]/text() )
            else( '0' )
          return
            replace( tokenize( $ч, ',' )[ last() ] , '\D', '' )
          )
      return
        if( $часов >= 256 )
        then( 'Профессиональная переподготовка' )
        else( 
          if( $часов >= 16 )
          then( 'Курсы повышения квалификации' )
          else( 'Консультации' )
        )
   
    group by $вид
    
    return
      $tpl( 'content/reports/report-plan-kpk/vid', map{'вид' : $вид, 'уровни' : $уровни, 'rows' : $i } )
};

declare 
  %private
function report:мероприятияПоВиду( $вид, $уровни, $rows ){
  <div>
      <h2>{ upper-case( $вид ) }</h2>
      <div>{
         for $k in $rows
         let $уровень := $k/cell[ @label = 'Уровень' ]/text()
         group by $уровень
         let $названиеУровня :=
           let $l :=
             $уровни/row[ cell[ @label = 'Сокращенное название' ] = $уровень ]
             /cell[ @label = 'Название']/text()
           return
             if( $l != '' )then( $l )else( $уровень )
            
        return
          <div>
            <h3>{ $названиеУровня }</h3>
            <div>{ report:table( $k ) }</div>
          </div>
      }</div>
    </div>
};