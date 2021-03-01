module namespace report = 'school/reports/teachers';
import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';


declare function report:main( $params ){
    map{ 'отчет' : report:table( $params ) }
};

declare function report:table( $params ){
 let $учителя :=
    $params?_data?getFile( '/Школы/Иваново/26_школа/Кадры.xlsx',  '.' )
 
let $строки := 
  for $i in $учителя/file/table[ 1 ]/row
  let $датаКатегории := 
    dateTime:dateParse( $i/cell[ @label = "Дата получения/подтверждения категории" ]/text() )
  let $датаПК := 
    dateTime:dateParse( $i/cell[ @label = "Дата прохождения КПК" ]/text() )
  let $курсыНужны := 
    $датаПК + xs:dayTimeDuration("P1095D") < xs:date( '2021-12-31' )
  where $курсыНужны
  let $фио := $i/cell[ @label = "Фамилия Имя Отчество" ]/text()
  return
    <tr>
      <td>{ $фио }</td>
      <td>{ $i/cell[ @label = "Должность" ]/text() }</td>
      <td class = "text-center">{ $датаПК }</td>
      <td class = "text-center">{ $датаПК + xs:dayTimeDuration("P1095D") }</td>
      <td class = "text-center"><input form = "teacher" type="checkbox" name="учитель" value="{ $фио }" checked = "yes"/></td>
    </tr>

 return
   <table class = "table table-striped">
     <thead>
       <tr class = "text-center">
        <th>Учитель</th>
        <th>Должность</th>
        <th>Дата последнего ПК</th>
        <th>Дата следующего ПК</th>
        <th>В заявку</th>
      </tr>
     </thead>
     <tbody class = "table ">{ $строки }</tbody>
   </table>
 };