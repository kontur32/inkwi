module namespace avatar = "header/avatar";


declare function avatar:main( $params as map(*) ){
  map{
    "userLabel" : 'Гость',
    "userAvatarURL" : $params?_config( 'defaultAvatarURL' )
  }
};