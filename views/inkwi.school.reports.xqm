module namespace inkwi = "inkwi/school/reports";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/unoi/sch/отчеты/{ $отчет }" )
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function inkwi:main( $отчет as xs:string ){
    
    let $params :=    
       map{
        'header' : funct:tpl2( 'school/header', map{} ),
        'content' : funct:tpl2( 'content/reports/report-plan-kpk', map{} ),
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