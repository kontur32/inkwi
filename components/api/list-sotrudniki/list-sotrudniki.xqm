module namespace list-sotrudniki = "api/list-sotrudniki";

(:
  возвращает список сотрудников
:)
declare function list-sotrudniki:main($params as map(*)){
    map{
      'сотрудники' :list-sotrudniki:сотрудники($params)
    }
};

declare 
  %private
function list-sotrudniki:сотрудники(
  $params
) as element(table)* {
  let $путь := "/УНОИ/Кафедры/Сводная.xlsx"
  let $xq := './/table[@label="Сотрудники"]'
  return
    $params?_data?getFile($путь, $xq)//table
};