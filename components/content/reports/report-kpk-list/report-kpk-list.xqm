module namespace report-kpk-list = 'content/reports/report-kpk-list';

import module namespace functx = "http://www.functx.com";
import module namespace dateTime = 'dateTime' 
  at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report-kpk-list:main($params){
    map{'список':report-kpk-list:всеСотрудники($params)}
};

declare 
  %private
function report-kpk-list:всеСотрудники(
  $params
){
  let $путь := "/УНОИ/Кафедры/Сводная.xlsx"
  let $xq := './/table[@label="Сотрудники"]'
  let $data := $params?_data?getFile($путь, $xq)//table
  for $i in $data/row
  let $кафедра := $i/cell[@label="Подразделение"]/text()
  order by $кафедра
  let $сотрудник := 
    $i/cell[@label="Фамилия"]/text() || ' ' ||
    $i/cell[@label="Имя"]/text()
  let $курсы := 
    report-kpk-list:данныеВсехКурсовСотрудника(
      $params,
      $кафедра,
      $сотрудник
    )
  where $курсы
  for $j in $курсы/@label/data()
  let $href :=
    web:create-url(
      '/unoi/u/отчеты/расписание-курса',
      map{
        'кафедра':$кафедра,
        'сотрудник':$сотрудник,
        'курс':$j
      }
    )
  return
    <li><a href="{$href}">{$j}</a> ({$сотрудник}, "{$кафедра}")</li>
};

declare 
  %private
function report-kpk-list:данныеВсехКурсовСотрудника(
  $params,
  $кафедра,
  $сотрудник
){
  let $путь := 
    functx:replace-multi(
      '/УНОИ/Кафедры/%1/Сотрудники/%2/КУГ.xlsx',
      ('%1', '%2'),
      ($кафедра, substring-before($сотрудник, ' '))
    )
  let $xq := '<data>{.//table update delete node ./row[position()<3]}</data>'
  return
    $params?_data?getFile($путь, $xq)//table
};