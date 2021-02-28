module namespace avatar = "school/header/avatar";

declare function avatar:main( $params as map(*) ){
  map{
    "userLabel" : session:get( 'displayName' ),
    "userAvatarURL" : if( session:get( 'userAvatarURL' ) != "")then( session:get( 'userAvatarURL' ) )else( $params?_config( 'defaultAvatarURL' ) ),
    "redirect" : "/unoi/sch"
  }
};