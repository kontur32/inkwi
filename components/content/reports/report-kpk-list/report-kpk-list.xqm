module namespace report-kpk-list = 'content/reports/report-kpk-list';

import module namespace functx = "http://www.functx.com";
import module namespace dateTime = 'dateTime' 
  at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report-kpk-list:main($params){
  map{'список':report-kpk-list:списокВсехКурсов($params)}
};

declare 
  %private
function report-kpk-list:списокВсехКурсов(
  $params
){
  let $курсыСотрудников := report-kpk-list:данныеВсехКурсов($params)
  for $i in $курсыСотрудников/курсыСотрудника
  let $сотрудник := $i/сотрудник/фамилия || ' ' || $i/сотрудник/имя
  let $кафедра := $i/сотрудник/кафедра/text()
  for $j in $i/курсы/table/@label/data()
  order by $сотрудник
  order by $кафедра
  let $href :=
    web:create-url(
      '/unoi/u/отчеты/расписание-курса',
      map{
        'кафедра' : $кафедра,
        'сотрудник' : $сотрудник,
        'курс'  : $j
      }
    )
  return
    <li><a href="{$href}" target="_blank">{$j}</a> ({$сотрудник}, "{$кафедра}")</li>
};


declare 
  %private
function report-kpk-list:данныеВсехКурсов(
  $params
) as element(курсы)* {
  let $data := $params?_tpl('api/list-sotrudniki', $params)/table
  let $курсыСотруника := 
    for $i in $data/row
    let $кафедра := $i/cell[@label="Подразделение"]/text()
    order by $кафедра
    let $сотрудник := 
      map{
        'фамилия' : $i/cell[@label="Фамилия"]/text(),
        'имя' : $i/cell[@label="Имя"]/text()
      }
    let $курсы := 
      report-kpk-list:данныеВсехКурсовСотрудника(
        $params,
        $кафедра,
        $сотрудник
      )
    where $курсы
    return
      $курсы
  return
    <курсы>{$курсыСотруника}</курсы>
};

declare 
  %private
function report-kpk-list:данныеВсехКурсовСотрудника(
  $params,
  $кафедра,
  $сотрудник
) as element(курсыСотрудника)* {
  let $путь := 
    functx:replace-multi(
      '/УНОИ/Кафедры/%1/Сотрудники/%2/КУГ.xlsx',
      ('%1', '%2'),
      ($кафедра, $сотрудник?фамилия)
    )
  let $xq := '<data>{.//table update delete node ./row[position()<3]}</data>'
  let $курсыСотрудника :=
    $params?_data?getFile($путь, $xq)//table
  return
    <курсыСотрудника>
      <сотрудник>
        <фамилия>{$сотрудник?фамилия}</фамилия>
        <имя>{$сотрудник?имя}</имя>
        <кафедра>{$кафедра}</кафедра>
      </сотрудник>
      <курсы>{$курсыСотрудника}</курсы>
    </курсыСотрудника>
};