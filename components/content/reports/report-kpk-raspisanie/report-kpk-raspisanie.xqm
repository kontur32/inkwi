module namespace report-kpk-raspisanie = 'content/reports/report-kpk-raspisanie';

import module namespace functx = "http://www.functx.com";
import module namespace dateTime = 'dateTime' 
  at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function report-kpk-raspisanie:main($params){
  let $кафедра := request:parameter('кафедра')
  let $сотрудник := request:parameter('сотрудник')
  let $курс := request:parameter('курс')
  let $data :=
    report-kpk-raspisanie:данныеКурса($params, $кафедра, $сотрудник, $курс)
  let $расписание := 
      <table class="table border">{report-kpk-raspisanie:расписание($data)}</table>
  return  
    map{
      'расписание':$расписание,
      'названиеКурса':$data/@label/data()
    }
};

declare 
  %private
function report-kpk-raspisanie:данныеКурса(
  $params,
  $кафедра,
  $сотрудник,
  $курс
){
  report-kpk-raspisanie:данныеВсехКурсовСотрудника($params, $кафедра, $сотрудник)
  [@label=$курс]
};

declare 
  %private
function report-kpk-raspisanie:данныеВсехКурсовСотрудника(
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

declare 
  %private
function report-kpk-raspisanie:расписание($data){
    let $даты := 
      distinct-values($data/row/cell[@label="Дата"]/dateTime:dateParse(text()))
    let $заголовок :=
      <tr>
        <th>№ пп</th>
        <th>Номер темы</th>
        <th>Название темы</th>
        {
          for $i in $даты
          order by $i
          let $дата := 
            replace(xs:string($i), '(\d{4})-(\d{2})-(\d{2})', '$3.$2.$1')
          return
            <th>{$дата}</th>
        }
        <th>Часов план</th>
        <th>Часов факт</th>
      </tr>
    let $строкиТем := 
      for $тема in $data/row
      let $номерТемы := $тема/cell[@label="Номер темы"]/text()
      let $названиеТемы := $тема/cell[@label="Наименование темы"]/text()
      where matches($номерТемы, 'Тема')
      count $c
      let $дата := $тема/cell[@label="Дата"]/dateTime:dateParse(text())
      let $часовПлан := $тема/cell[@label="Часов"]/text()
      let $времяНачалаЧислом :=  $тема/cell[@label="Время начала"]/text()
      let $времяОкончанияЧислом :=  $тема/cell[@label="Время окончания"]/text()
      let $продолжительность :=
        if($времяОкончанияЧислом and $времяНачалаЧислом)
        then(
           report-kpk-raspisanie:времяНачала(
              ($времяОкончанияЧислом - $времяНачалаЧислом) * 60 div 45
           )
        )
        else()
      return
        <tr>
          <td>{$c}.</td>
          <td>{$номерТемы}</td>
          <td>{$названиеТемы}</td>
          {
            for $i in $даты
            let $записьЗанятие := report-kpk-raspisanie:занятие($тема)
            return
              <td>{xs:date($дата)=$i??$записьЗанятие!!""}</td>
          }
          <td>{$часовПлан}</td>
          <td>{$продолжительность}</td>
        </tr>
  return
    ($заголовок, $строкиТем)
};

declare 
  %private
function report-kpk-raspisanie:занятие($тема){
    let $времяНачалаЧислом :=  $тема/cell[@label="Время начала"]/number()
    let $времяОкончанияЧислом :=  $тема/cell[@label="Время окончания"]/number()
    let $времяНачала := report-kpk-raspisanie:времяНачала($времяНачалаЧислом)
    let $времяОкончания := report-kpk-raspisanie:времяНачала($времяОкончанияЧислом)
    let $преподаватель :=  $тема/cell[@label="ФИО преподавателя"]/text()
    let $аудитория :=  $тема/cell[@label="Аудитория"]/text()
    return
      (
        <span>{$времяНачала} - {$времяОкончания}, </span>, 
        <span>{$преподаватель}, </span>,
        <span>{$аудитория}</span>
      )
};

declare 
  %private
function report-kpk-raspisanie:времяНачала($времяЧислом){
  let $часы := floor(24 * $времяЧислом)
  let $минуты := round((24 * $времяЧислом - floor(24 * $времяЧислом)) * 60)
  let $дополнительныйНоль := string-length(xs:string($минуты))=1??"0"!!""
  return
    $часы || ":" || $минуты || $дополнительныйНоль
};