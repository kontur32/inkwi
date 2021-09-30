module namespace vid = 'content/reports/report-plan-kpk/vid';

import module namespace dateTime = 'dateTime' at 'http://iro37.ru/res/repo/dateTime.xqm';

declare function vid:main( $params ){
  let $отчет:= 
      <div id="accordion" class = 'shadow mb-4' вид = "{ $params?вид }">
        
          <h3>{ $params?вид }</h3>
          
          <div>{
             for $k in $params?rows
             let $уровень := $k/cell[ @label = 'Уровень' ]/text()
             group by $уровень
             let $названиеУровня :=
               let $l :=
                 $params?уровни/row[ cell[ @label = 'Сокращенное название' ] = $уровень ]
                 /cell[ @label = 'Название']/text()
               return
                 if( $l != '' )then( $l )else( $уровень )
            count $c
            let $v := web:encode-url( $params?вид )    
            return
                <div class="card" уровень = "{ $уровень }">
                  <div class="card-header text-left" id="{ 'headingOne' || $params?номер || $c }">
                    <button class="btn btn-link collapsed" data-toggle="collapse" data-target="{ '#collapseOne' || $params?номер || $c }" aria-expanded="true" aria-controls="collapseOne">
                      <h5 class = "text-left">{ $названиеУровня }</h5>
                    </button>
                  </div>
                  
                  <div id="{ 'collapseOne' || $params?номер || $c }" class="collapse" aria-labelledby="{ 'headingOne' || $params?номер || $c }" data-parent="#accordion">
                    <div class="card-body">
                      { vid:table( $k, $params?вид, $названиеУровня ) }
                    </div>
                  </div>
                  
                </div>
              
          }</div>
        
      </div>
  return
    map{ 'отчет' : $отчет }
};

declare function vid:ifNotEmpty( $str, $var ){
    if( $var )
    then( ( $str, <div>{ $var }</div> ) )
    else()
  };

declare function vid:date( $var ){
  replace(
      xs:string(
        dateTime:dateParse( $var )
      ),
      '(\d{4})-(\d{2})-(\d{2})',
      '$3.$2.$1'
    ) 
};

declare function vid:table( $i, $вид, $уровень){
  <table class = "table table-bordered" вид = "{ $вид }" уровень = "{ $уровень }" width="100%">
        <thead>
          <tr class = 'text-center'>
            <th class = 'align-middle' width="20%">Категория слушателей</th>
            <th class = 'align-middle' width="40%">Название дополнительной профессиональной программы, аннотация</th>
            <th class = 'align-middle' width="10%">Объем программы, час</th>
            <th class = 'align-middle' width="10%">Сроки обучения, час.</th>
            <th class = 'align-middle' width="10%">Стоимость, рублей</th>
            <th class = 'align-middle' width="10%">Руководитель курсов</th>
          </tr>
        </thead>
        <tbody>
          {
          for $j in $i
          let $id :=
            if( $j/cell[ @label = 'Курс в Мудл']/text() )
            then(
              <a class = "btn btn-success" href = "{ $j/cell[ @label = 'Курс в Мудл']/text() }">Посмотреть курс</a>
            )
            else()
            
          return
            <tr>
              <td>{ $j/cell[ @label = 'Целевая категория']/text() }{ $id }</td>
              <td>
                <b><i>{ $j/cell[ @label = 'Название ДПП']/text() }</i></b><br/>
                {
                  vid:ifNotEmpty(
                    <b>В программе:</b>,
                   $j/cell[ @label = 'В программе']/text()
                  )
                }
                {
                  vid:ifNotEmpty(
                    <b>Результат обучения:</b>,
                    $j/cell[ @label = 'В результате обучения']/text()
                  )
                }
                {
                  vid:ifNotEmpty(
                    <b>Итоговая аттестация:</b>,
                    $j/cell[ @label = 'Итоговая аттестация']/text()
                  )
                }
                {
                  (
                    <b>Кафедра:</b>,
                    <div>{ lower-case( $j/cell[ @label = 'Кафедра' ]/text() ) }</div>
                  )
                }
              </td>
              <td class = 'text-center'>{ $j/cell[ @label = 'Объем']/text() }</td>
              <td class = 'text-center'>
                { vid:date( $j/cell[ @label = 'Начало КПК']/text() ) }-
                { vid:date( $j/cell[ @label = 'Окончание КПК']/text() ) }
                {
                  vid:ifNotEmpty(
                    <div>Очный этап:</div>,
                    $j/cell[ @label = 'Дни очного обучения']/text()
                  )
                }
              </td>
              <td class = 'text-center'>{ $j/cell[ @label = 'Стоимость обучения']/text() }</td>
              <td>{ $j/cell[ @label = 'Руководитель КПК']/text() }</td>
            </tr>
          }
        </tbody>
      </table>
};