(:
  временный, нигде не используется
  формирование таблицы для вненсения в шабон ворд
:)

module namespace inkwi = "inkwi";

import module namespace funct="funct" at "../functions/functions.xqm";
import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';
import module namespace config = "app/config" at "../functions/config.xqm";
import module namespace getData = "getData" at "../functions/getData.xqm";

declare 
  %rest:GET
  %rest:path( "/unoi/api/v01/lists/courses/{ $id }/{ $date }" )
  %output:method( "xml" )
function inkwi:cours( $id, $date as xs:date ){
  let $funct :=
    function( $id1, $date1 ){
      <data>
        <table>{
          inkwi:allCourses()
          /data/file/table/row
          [ cell [ @label = "Курс в Мудл"]/substring-after( text(), '?id=' ) =  $id1  ]
          [ cell [ @label = "Начало КПК"]/dateTime:dateParse( text() ) = xs:date( $date1 ) ]
        }</table>
      </data>
    }
  return
    $funct( $id, $date )
};

declare 
  %rest:GET
  %rest:path( "/unoi/api/v01/lists/courses" )
  %output:method( "xml" )
function inkwi:allCourses(){
   getData:getData( 
    config:param( 'host' ) || '/static/unoi/xq/coursesList.xq',
    map{ 'cache' : '600' },
    getData:getToken(
      $config:param( 'authHost' ),
      $config:param( 'login' ),
      $config:param( 'password' )
    )
  )
};

declare function inkwi:getResource( $funct ){
  let $hash :=  xs:string( xs:hexBinary( hash:md5( request:uri() ) ) )
  let $resPath := config:param( 'cache.dir' ) || $hash
  let $mod :=
    function( $resPath1 ){
      minutes-from-duration( current-dateTime() - file:last-modified( $resPath1 ) )
    }
  
  let $cache := 
    if( file:exists( $resPath ) )
    then(
      if( $mod( $resPath ) < 5 )
      then(
        try{ doc( $resPath  ) }catch*{}
      )
      else(
        let $res2 := try{ $funct }catch*{}
        let $w := file:write( config:param( 'cache.dir' ) || $hash, $res2 )
        return
           $res2
      )
    )
    else(
      let $res2 := try{ $funct }catch*{}
      let $w := file:write( config:param( 'cache.dir' ) || $hash, $res2 )
      return
         $res2
    )
  return
    $cache
};