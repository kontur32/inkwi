module namespace list-departments = "api/list-departments";

(:
  возвращает список подразделений
:)
declare function list-departments:main($params as map(*)){
    map{
      'подразделения' : list-departments:список($params)
    }
};

declare 
  %private
function list-departments:список(
  $params
) as element(table)* {
  let $путь := "/УНОИ/Кафедры/Сводная.xlsx"
  let $xq := './/table[@label="Подразделения"]'
  return
    $params?_data?getFile($путь, $xq)//table
};