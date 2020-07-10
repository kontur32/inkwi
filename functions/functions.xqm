module namespace funct = "funct";

import module namespace getData = "getData" at "getData.xqm";
import module namespace config = "app/config" at "../functions/config.xqm";

declare function funct:log( $fileName, $data, $params ) {
  switch ( $params?mode )
  case 'rewrite'
    return
      file:write-text(
           funct:param( 'logDir' ) || $fileName,
            string-join( ( current-dateTime() || '--' || $data, '&#xD;&#xA;' ) )
         )
    case 'add'
    return
      file:append-text(
           funct:param( 'logDir' ) || $fileName,
            string-join( ( current-dateTime() || '--' || $data, '&#xD;&#xA;' ) )
         )
   default 
     return
     file:append-text(
         funct:param( 'logDir' ) || $fileName,
          string-join( ( current-dateTime() || '--' || $data, '&#xD;&#xA;' ) )
       )
       
};

declare function funct:log ( $fileName, $data ) {
  funct:log( $fileName, $data, map{ 'mode' : 'add' } )
};

declare function funct:param ( $param ) {
   doc( "../config.xml" )/config/param[ @id = $param ]/text()
};

declare function funct:xhtml( $app as xs:string, $map as item() ){
  let $string := file:read-text( file:base-dir() || '../components/' || $app || "/main.tpl.html" )
  return
    parse-xml(
      funct:replace( $string, $map )
    )
};

declare function funct:replace( $string, $map ){
  fold-left(
        map:for-each( $map, function( $key, $value ){ map{ $key : $value } } ),
        $string, 
        function( $string, $d ){
           replace(
            $string,
            "\{\{" || map:keys( $d )[ 1 ] || "\}\}",
            replace( serialize( map:get( $d, map:keys( $d )[ 1 ] ) ), '\\', '\\\\' ) (: проблема \ в заменяемой строке :)
          ) 
        }
      )
};

declare function funct:tpl( $app, $params ){
  let $queryTpl := '
    import module namespace {{appAlias}} = "{{app}}" at "../components/{{app}}/main.xqm";  
    declare variable $params external;
    {{appAlias}}:main( $params )'
  let $appAlias := if( contains( $app, "/") ) then( substring-before( $app, "/") ) else( $app )
  let $query := replace(
    replace( $queryTpl, "\{\{app\}\}", $app ), "\{\{appAlias\}\}", $appAlias
  )
  return
    xquery:eval(
      $query, 
      map{ 'params': $params }
    )
};


(:------------------ новый механизм -----------------------------------------:)

declare function funct:xhtml2( $app as xs:string, $map as item(), $componentPath ){
  let $appAlias := if( contains( $app, "/") ) then( tokenize( $app, "/" )[ last()] ) else( $app )
  let $string := 
    file:read-text(
      file:base-dir() || $componentPath ||  '/' || $app || "/"  || $appAlias || ".html"
    )
  
  return
    parse-xml(
      funct:replace( $string, $map )
    )
};

declare function funct:tpl2( $app, $params ){
  let $componentPath := '../components'
  let $queryTpl := '
    import module namespace {{appAlias}} = "{{app}}" at "{{rootPath}}/{{app}}/{{appAlias}}.xqm";  
    declare variable $params external;
    {{appAlias}}:main( $params )'
  
  let $appAlias := 
    if( contains( $app, "/") ) then( tokenize( $app, "/")[ last() ] )  else( $app )
  
  let $query := 
    funct:replace(
      $queryTpl,
      map{
        'rootPath' : $componentPath,
        'app' : $app,
        'appAlias' : $appAlias
      }
    )
  
  let $tpl := function( $app, $params ){ funct:tpl2( $app, $params ) }
  let $config := function( $param ){ $config:param( $param ) }
  
  let $result :=
    prof:track( 
      xquery:eval(
          $query, 
          map{ 'params':
            map:merge( 
              ( $params, map{ '_tpl' : $tpl, '_data' : $getData:funct, '_config' : $config:param } )
            )
          }
        )
      )
  let $log :=
    funct:log(
      'profiling.log',
      $app || '--' || $result?time,
      map{'mode' : 'rewrite'}
    )
  return
     funct:xhtml2( $app, $result?value, $componentPath )
};