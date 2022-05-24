module namespace list-courses = "api/list-courses";

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function list-courses:main( $params as map(*) ){
  let $data := 
     $params?_data?getFile( '/УНОИ/Кафедры/Сводная.xlsx',  '.' )
  return
    map{
      'списокКурсов' :
        <data>
          <спискиКурсов>{list-courses:всеКурсы($params, $data) }</спискиКурсов>
          <сводная>{$data}</сводная>
        </data>
    }
};

declare
  %private
function list-courses:всеКурсы($params, $data ) as element(file)* {
  let $кафедры := 
    $data//table[@label="Подразделения"]/row[cell[@label="Тип"]/text() = "Кафедра"]/cell[@label="Название"]/text()
  for $кафедра in $кафедры
  let $путь :=
    replace(
      "/УНОИ/Кафедры/%1/Курсовые мероприятия кафедры.xlsx","%1", $кафедра
    )
  return
    $params?_data?getFile($путь, '.')//file 
    update insert node attribute подразделение {$кафедра} into .
};