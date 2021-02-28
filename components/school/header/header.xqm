module namespace header = "school/header";

declare function header:main( $params as map(*) ){
  map{
    'mainMenu' : $params?_tpl( 'school/header/mainMenu', map{} ),
    'avatar' : $params?_tpl( 'school/header/avatar', map{} )
  }  
};