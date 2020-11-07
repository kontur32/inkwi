module namespace check = "check";


declare 
  %perm:check( "/unoi/u" )
function check:userArea(){
  let $user := session:get( "login" )
  where empty( $user )
  return
    web:redirect("/unoi")
};