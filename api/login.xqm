module namespace login = "login";

declare 
  %rest:GET
  %rest:query-param( "login", "{ $login }" )
  %rest:query-param( "password", "{ $password }" )
  %rest:path( "/unoi/api/v01/login" )
function login:main( $login as xs:string, $password as xs:string ){
  if( $login = "unoi" )
  then(
    session:set( "login", "unoi" ),
    web:redirect( "/unoi/u" )
  )
  else( web:redirect( "/unoi" ) )
};