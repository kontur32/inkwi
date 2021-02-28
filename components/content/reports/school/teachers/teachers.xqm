module namespace report = 'content/reports/school/teachers';
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
  let $шрифт := 
    $курсыНужны ?? 'font-weight-bold' !! 'font-weight-normal'
  return
    <tr>
      <td class = "{ $шрифт }">{ $i/cell[ @label = "Фамилия Имя Отчество" ]/text() }</td>
      <td>{ $i/cell[ @label = "Должность" ]/text() }</td>
      <td class = "text-center">{ $i/cell[ @label = "Квалификационная категория" ]/text() }</td>
      <td>{ $датаКатегории }</td>
      <td>{ $датаКатегории + xs:dayTimeDuration("P1825D") }</td>
      <td>{ $датаПК }</td>
      <td class = "{ $шрифт }">{ $датаПК + xs:dayTimeDuration("P1095D") }</td>
    </tr>

 return
   <table class = "table table-striped">
     <thead>
       <tr>
        <th>Учитель</th>
        <th>Должность</th>
        <th>Категория</th>
        <th>Дата получение категории</th>
        <th>Дата подтверждения категории</th>
        <th>Дата последнего ПК</th>
        <th>Дата следующего ПК</th>
      </tr>
     </thead>
     <tbody class = "table ">{ $строки }</tbody>
   </table>
 };