module namespace login = "login";

declare function login:main( $params as map(*) ){
  map{
    'redirect' : $params?redirect
  }
};