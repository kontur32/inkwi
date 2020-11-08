module namespace inkwi = "inkwi/user";

import module namespace funct="funct" at "../functions/functions.xqm";

declare 
  %rest:GET
  %rest:path( "/unoi/u" )
  %output:method( "xhtml" )
  %output:doctype-public( "www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" )
function inkwi:main(){
    let $form :=
      let $форма := fetch:xml(
        "http://dbx.iro37.ru/zapolnititul/v/forms?path=http://iro37.ru/xqwiki/images/0/03/%D0%A8%D0%B0%D0%B1%D0%BB%D0%BE%D0%BD_%D1%81%D0%BB%D1%83%D0%B6%D0%B5%D0%B1%D0%BD%D0%BE%D0%B5_%D0%BF%D0%B8%D1%81%D1%8C%D0%BC%D0%BE_%D0%A3%D0%9D%D0%9E%D0%98.docx"
      )
      return
        $форма//div[ h2 and h4 ] update insert node <input name = "_t24_outputFormat" value = "docx" hidden = "yes"></input> into .//form
    
    let $содержание :=
      <div>
        Главная страница сервиса <span>"Электронный вассал методиста"</span>
        <hr/>
        Выберите нужный пункт меню
        <hr/>
        <div class = "row">
          <div class = "col-md-8 offset-md-2 shadow bg-white rounded">{ $form }</div>
        </div>
      </div>
    
    let $params :=    
       map{
        'header' : funct:tpl2( 'header', map{} ),
        'content' : $содержание,
        'footer' : funct:tpl2( 'footer', map{} )
      }
    return
      funct:tpl2( 'main', $params )
};