module namespace login = "login";

declare 
  %rest:GET
  %rest:query-param( "login", "{ $login }" )
  %rest:query-param( "password", "{ $password }" )
  %rest:path( "/unoi/api/v01/login" )
function login:main( $login as xs:string, $password as xs:string ){
  
  if( $login = "unoi" )
  then(
    session:set( "login", $login ),
    session:set( "displayName", "Гость"),
    session:set( "grants", "гость"),
    web:redirect( "/unoi/u" )
  )
  else(
    let $user :=  login:getUserMeta( $login, $password )
    let $displayName := 
      if( $user/displayname/text() = "" )
      then( $login )
      else( $user/displayname/text() )
     let $avatarURL :=
         fetch:xml( 'http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/c48c07c3-a998-47bf-8e33-4d6be40bf4a7' )
       /file/table[ @label = 'Сотрудники' ]
       /row[ cell[ @label = 'Логин'] = $login ]
       /cell[ @label = 'Фото' ]/text()
       
    
    return
      if( namespace-uri( $user ) != 'http://www.w3.org/2005/xqt-errors' )
      then(
        session:set( "login", $login ),
        session:set( "displayName", $displayName ),
        session:set( 'userAvatarURL', $avatarURL),
        web:redirect( "/unoi/u" ) 
      )
      else( web:redirect( "/unoi" ) )
    )
};

declare function login:getUserMeta( $login, $password ){
  let $path := '/unoi/ocs/v1.php/cloud/users/'
  let $url := 'http://roz37.ru' || $path || $login
  
  let $auth := xs:string( convert:string-to-base64( $login || ':' || $password ) )
  let $response :=
    http:send-request(
        <http:request method='GET'
           href= "{ $url }">
          <http:header name="Authorization" value= '{ "Basic " || $auth }' />
          <http:header name="OCS-APIRequest" value= 'true' />
        </http:request>
      )[2]
      
  return
    if( $response/ocs/meta/status/text() = 'ok' )
    then(
        <user>
          {
            $response/ocs/data/displayname,
            $response/ocs/data/groups
          }
        </user>
    )
    else( <err:LOGINGFAILED></err:LOGINGFAILED>)
};