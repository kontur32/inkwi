module namespace logout = "logout";

declare 
  %rest:GET
  %rest:query-param( "redirect", "{ $redirect }", "/unoi" )
  %rest:path( "/unoi/api/v01/logout" )
function logout:main( $redirect ){
  session:close(),
  web:redirect( $redirect )
};
