module namespace report = 'content/reports/report-plan-kpk';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report:main( $params ){
   let $data := 
     fetch:xml(
       'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/c48c07c3-a998-47bf-8e33-4d6be40bf4a7'
      )
   let $отчет :=
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
        count $c
        return
          $params?_tpl(
            'content/reports/report-plan-kpk/vid',
            map{ 'вид' : $вид, 'номер' : $c, 'уровни' : $уровни, 'rows' : $i }
          )
   
   return
     map{ 'отчет' : $отчет }
};