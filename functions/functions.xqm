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

declare function funct:xhtml( $app as xs:string, $map as item(), $componentPath ){
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
  let $config := function( $param ){ config:param( $param ) }
  let $getFile := function( $path, $xq ){ getData:getFile( $path, $xq ) }
  let $getData := 
    map{
      'getFile' : $getFile,
      'getData' : function( $xquery, $params ){ getData:getData( $xquery, $params ) }
    }
  
  let $result :=
      xquery:eval(
          $query, 
          map{ 'params':
            map:merge( 
              ( $params, map{ '_tpl' : $tpl, '_data' : $getData, '_config' : $config } )
            )
          }
        )

  return
     funct:xhtml( $app, $result, $componentPath )
};