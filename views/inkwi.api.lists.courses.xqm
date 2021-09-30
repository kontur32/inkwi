(:
  временный, нигде не используется
  формирование таблицы для вненсения в шабон ворд
:)

module namespace inkwi = "inkwi";

import module namespace funct="funct" at "../functions/functions.xqm";
import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';
import module namespace config = "app/config" at "../functions/config.xqm";

declare 
  %rest:GET
  %rest:path( "/unoi/api/v01/lists/courses/{ $id }/{ $date }" )
  %output:method( "xml" )
function inkwi:cours( $id, $date as xs:date ){
  let $filter :=
    function( $node as element(row), $courseID ){
      let $programmID := substring-before( $courseID, '/' )
      let $startDate := substring-after( $courseID, '/' )
      return
        $node
        [ cell [ @label = "Курс в Мудл"]/substring-after( text(), '?id=' ) =  $programmID  ]
        [ cell [ @label = "Начало КПК"]/dateTime:dateParse( text() ) = xs:date( $startDate ) ]
    }
  return
    <data>
      <table>{
        fetch:xml(
          'http://localhost:9984/unoi/api/v01/lists/courses'
        )/data/спискиКурсов/file/table/row[ $filter( ., $id || '/' || $date ) ]
      }</table>
    </data> 
};

declare 
  %rest:GET
  %rest:path( "/unoi/api/v01/lists/courses/{ $id }" )
  %output:method( "xml" )
function inkwi:courses( $id ){
  <data>{
    funct:tpl2( 'api/list-courses', map{ } )
    /data/спискиКурсов/file/table/row
    [ cell [ @label = "Курс в Мудл"]/substring-after( text(), '?id=' ) = $id ]
  }</data>
};

declare 
  %rest:GET
  %rest:path( "/unoi/api/v01/lists/courses" )
  %output:method( "xml" )
function inkwi:allCourses(){
  let $hash :=  xs:string( xs:hexBinary( hash:md5( request:uri() ) ) )
  let $cache := 
      let $res := try{ doc( config:param( 'cache.dir' ) || $hash ) }catch*{}
      return
        if( not( $res ) )
        then(
          let $res2 := 
            try{
              funct:tpl2( 'api/list-courses', map{ } )
            }catch*{}
          let $w := file:write( config:param( 'cache.dir' ) || $hash, $res2 )
          return
             $res2
        )
        else( $res )
  return
    $cache
};