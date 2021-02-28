module namespace report = 'school/reports/teachers-category';
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
  let $подтверждениеКатегории := 
    $датаКатегории + xs:dayTimeDuration( "P1825D" ) < xs:date( '2021-12-31' )
  where $подтверждениеКатегории
  return
    <tr>
      <td>{ $i/cell[ @label = "Фамилия Имя Отчество" ]/text() }</td>
      <td class = "text-center">{ $i/cell[ @label = "Должность" ]/text() }</td>
      <td class = "text-center">{ $i/cell[ @label = "Квалификационная категория" ]/text() }</td>
      <td class = "text-center">{ $датаКатегории }</td>
      <td class = "text-center">{ $датаКатегории + xs:dayTimeDuration("P1825D") }</td>
    </tr>

 return
   <table class = "table table-striped">
     <thead>
       <tr class = "text-center">
        <th>Учитель</th>
        <th>Должность</th>
        <th>Категория</th>
        <th>Дата получения</th>
        <th>Дата подтверждения</th>
      </tr>
     </thead>
     <tbody class = "table ">{ $строки }</tbody>
   </table>
 };