module namespace inkwi = "inkwi/user";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/unoi/u/отчеты/{ $отчет }" )
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function inkwi:main( $отчет as xs:string ){
    
    let $содержание :=
      map{ 'раздел' : 'content/reports', 'страница' : $отчет }
    
    let $params :=    
       map{
        'header' : funct:tpl2( 'header', map{} ),
        'content' : funct:tpl2( 'content', $содержание ),
        'footer' : funct:tpl2( 'footer', map{} )
       }
    return
      funct:tpl2( 'main', $params )
};