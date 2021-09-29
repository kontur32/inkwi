(:
  временный, нигде не используется
  формирование таблицы для вненсения в шабон ворд
:)

module namespace inkwi = "inkwi";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/unoi/api/v01/lists/courses2" )
  %output:method( "xml" )
function inkwi:main2(){
  funct:tpl2( 'api/list-courses', map{ } )
};

declare 
  %rest:GET
  %rest:path( "/unoi/api/v01/lists/courses" )
  %output:method( "xml" )
function inkwi:main(){
  let $params :=    
   map{
    'content' : funct:tpl2( 'api/list-courses', map{ } ),
    'report' : funct:tpl2( 'content/reports/report-plan-kpk' , map{ } )
  }
  
  let $funct2 :=
    function( $var ){ $var/child::*[ name() = 'tr' ]/child::*[ name() = ( 'td', 'th') ] }
  let $funct1 :=
    function( $var ){ $var/child::*[ name() = 'tr' ] }
  
  let $table := $params?report//div[ @вид ][ 1 ]//div[ @уровень ][ 1 ]//table/tbody
  return
     <table>{
       inkwi:r( inkwi:r( $table, 'cell', $funct2 ), 'row', $funct1 )/row
     }</table>
};

declare function inkwi:r( $node, $name, $funct ){
  
    if( $funct( $node ) )
    then(
      inkwi:r( $node update  rename node $funct( . )[ 1 ] as $name, $name, $funct )
    )
    else( $node )
};