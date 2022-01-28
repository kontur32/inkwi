module namespace inkwi = "inkwi/user";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/unoi/p/отчеты/календарный-план" )
  %rest:query-param('output', '{$output}', '')
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function inkwi:планГрафик($output){
  let $страница :=
    if($output='print')
    then("календарный-план-печать")
    else("календарный-план")
  
  let $содержание :=
      map{
        'раздел' : 'content/reports',
        'страница' : $страница
      }
    
    let $params :=    
       map{
        'header' : '',
        'content' : funct:tpl2( 'content', $содержание ),
        'footer' : funct:tpl2( 'footer', map{} )
        
       }
    return
      funct:tpl2( 'main', $params )
};


declare 
  %rest:GET
  %rest:path( "/unoi/u/отчеты/{ $отчет }/печать" )
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function inkwi:отчетыПечать($отчет as xs:string){
  let $содержание :=
      map{
        'раздел' : 'content/reports',
        'страница' : $отчет,
        'query-params' : inkwi:query-params()
      }
    
    let $params :=    
       map{'content' : funct:tpl2( 'content', $содержание )}
    return
      funct:tpl2( 'main', $params )
};

declare 
  %rest:GET
  %rest:path( "/unoi/u/отчеты/{ $отчет }" )
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function inkwi:main( $отчет as xs:string ){
    
    let $содержание :=
      map{
        'раздел' : 'content/reports',
        'страница' : $отчет,
        'query-params' : inkwi:query-params()
      }
    
    let $params :=    
       map{
        'header' : funct:tpl2( 'header', map{} ),
        'content' : funct:tpl2( 'content', $содержание ),
        'footer' : funct:tpl2( 'footer', map{} )
        
       }
    return
      funct:tpl2( 'main', $params )
};

declare function inkwi:query-params() as map(*){
  map:merge(
    for $i in request:parameter-names()
    return
      map{ $i : request:parameter( $i ) }
    )
};