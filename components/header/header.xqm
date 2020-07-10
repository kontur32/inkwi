module namespace header = "header";

declare function header:main( $params as map(*) ){
  map{
    'mainMenu' : $params?_tpl( 'header/mainMenu', map{} ),
    'avatar' : $params?_tpl( 'header/avatar', map{} )
  }  
};