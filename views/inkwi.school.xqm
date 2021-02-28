module namespace inkwi = "inkwi/school";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/unoi/sch" )
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function inkwi:main(){
  let $содержание :=
    <div class = "row">
      <div class = "col-md-12 bg-white">личный кабинет школы<br/>
      { funct:tpl2( 'content/reports/school/teachers', map{} ) }</div>
    </div>
  
  let $params :=    
     map{
      'header' : funct:tpl2( 'header/school', map{} ),
      'content' : $содержание,
      'footer' : funct:tpl2( 'footer', map{} )
    }
  return
    funct:tpl2( 'main', $params )
};