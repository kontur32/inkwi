module namespace list-courses = "api/list-courses";

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function list-courses:main( $params as map(*) ){
  let $data := 
     $params?_data?getFile( '/УНОИ/Кафедры/Сводная.xlsx',  '.' )
  return
    map{
      'списокКурсов' :
        <data>
          <спискиКурсов>{ list-courses:всеКурсы( $params )  }</спискиКурсов>
          <сводная>{ $data }</сводная>
        </data>
         
    }
};

declare function list-courses:всеКурсы( $params ){
  $params?_data?getData(
    $params?_config( 'host' ) || '/static/unoi/xq/coursesList.xq', map{ 'cache' : '300' }
  )/data/file
};