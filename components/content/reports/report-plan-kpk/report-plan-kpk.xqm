module namespace report = 'content/reports/report-plan-kpk';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report:main( $params ){
   
   let $d :=
     $params?_tpl( 'api/list-courses', map{} )/data
   
   let $data := $d//сводная
   let $курсы := $d//спискиКурсов/file//row
     
   let $отчет :=
     let $уровни := $data//table[ @label = 'Уровни' ]
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
        count $c
        return
          $params?_tpl(
            'content/reports/report-plan-kpk/vid',
            map{ 'вид' : $вид, 'номер' : $c, 'уровни' : $уровни, 'rows' : $i }
          )
   
   return
     map{ 'отчет' : $отчет }
};