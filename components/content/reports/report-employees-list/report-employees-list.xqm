module namespace report-employees-list = "content/reports/report-employees-list";

(:
  формирует список сотрудников по подразделениям
:)
declare function report-employees-list:main($params as map(*)){
    map{
      'сотрудники' : report-employees-list:сотрудники($params?_tpl('api/list-departments', map{}), $params?_tpl('api/list-sotrudniki', map{}))
    }
};

declare 
  %private
function report-employees-list:сотрудники($подразделения, $сотрудники)
  as element()* 
{
  for $подразделение in $подразделения//row
  let $названиеПодразделения := $подразделение/cell[@label="Название"]/text()
  let $сотрудникиПодразделения :=
    $сотрудники//row[cell[@label="Подразделение"]=$названиеПодразделения]
  return
    <ul><span class="h3">{$названиеПодразделения}</span>{
      for $сотрудник in $сотрудникиПодразделения
      order by $сотрудник/cell[@label="Порядок"]/text()
      return
        <li>{$сотрудник/cell[@label="Фамилия"]} {$сотрудник/cell[@label="Имя"]} {$сотрудник/cell[@label="Отчество"]} ({$сотрудник/cell[@label="Должность"]})</li>
    }</ul>

   
};