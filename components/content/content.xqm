module namespace content = 'content';

declare function content:main( $params ){
    map{
      'содержание' : $params?_tpl( $params?раздел, map{ 'страница' : $params?страница } )
    }
};