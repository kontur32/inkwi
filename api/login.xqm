module namespace login = "login";

import module namespace getData = "getData" at "../functions/getData.xqm";
import module namespace config = "app/config" at "../functions/config.xqm";

declare 
  %rest:GET
  %rest:query-param( "login", "{ $login }" )
  %rest:query-param( "password", "{ $password }" )
  %rest:query-param( "redirect", "{ $redirect }", "/unoi/u" )
  %rest:path( "/unoi/api/v01/login" )
function login:main( $login as xs:string, $password as xs:string, $redirect ){
  
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

    let $accessToken := 
      getData:getToken(
          $config:param( 'authHost' ),
          $config:param( 'login' ),
          $config:param( 'password' )
        )
    
    let $avatarURL :=
      getData:getFile(
        '/УНОИ/Кафедры/Сводная.xlsx',
        '.',
        $config:param( 'fileStore.Saas.main' ),
        $accessToken
      )
      /file/table[ @label = 'Сотрудники' ]
      /row[ cell[ @label = 'Логин'] = $login ]
      /cell[ @label = 'Фото' ]/text()
      
    return
      if( namespace-uri( $user ) != 'http://www.w3.org/2005/xqt-errors' )
      then(
        session:set( 'accessToken', $accessToken ),
        session:set( "login", $login ),
        session:set( "displayName", $displayName ),
        session:set( 'userAvatarURL', $avatarURL),
        web:redirect( $redirect ) 
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