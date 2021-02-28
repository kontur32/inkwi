module namespace header = "header/school";

declare function header:main( $params as map(*) ){
  map{
    'mainMenu' : $params?_tpl( 'header/school/mainMenu', map{} ),
    'avatar' : $params?_tpl( 'header/avatar', map{} )
  }  
};