declare variable $params external;

declare function local:data( $data ){ 
  for $i in $data
  let $t := $i/cell[ @label = 'Учитель_замещение' ]/text()
  order by $t
  group by $t
  where $t
  count $c1
  return
    <i t='{ $t }'>{
      for $ii in $i
      let $z := $ii/cell[ @label = 'Учитель' ]/text()
      order by $z
      group by $z
      count $c2
      return 
        <ii z = '{ $z }'>{
          for $iii in $ii
           let $p := $iii/cell[ @label = 'Предмет_замещение' ]/text()
           order by $p
           group by $p
           count $c2

           return 
              <iii p = '{ $p }'>{
                for $iiii in $iii
                let $cl := $iiii/cell[ @label = 'Класс' ]/text()
                 order by $cl
                 group by $cl
                 count $c3
                 let $классов := distinct-values( $iii/cell[ @label = 'Класс']/text() )
                 
                 return
                   <tr>
                     <td>{ $cl }</td>
                     <td >{ count( $iiii ) }</td>
                   </tr>
              }</iii>
        }</ii>
    }</i>
};

declare function local:table( $data, $params ){
  <table border = '1px' style = "width : 50%" bgcolor="#FFFFFF" bordercolor="#000000" cellspacing="0" cellpadding="0">
    <tr style = "text-align: center; font-weight: bold;">
      <td>№ пп</td>
      <td>Ф.И.О. учителя, заменившего урок</td>
      <td>Ф.И.О. учителя, пропустившего урок</td>
      <td>Учебный предмет</td>
      <td>Класс</td>
      <td>Кол-во часов</td>
      <td style = "font-style: italic; font-weight: normal;" rowspan = '{ count( $data//tr ) + 2 + count( $data )}'> { $params?text }</td>
    </tr>
    {
     for $i in $data
     count $c1
     return
       for $ii in $i/ii
       count $c2
       return
         for $iii in $ii/iii
         count $c3
         return
           for $tr in $iii/tr
           count $c4
           return
             (
             <tr>
               {
                 if( $c2 = 1 and $c3 = 1 and $c4 = 1 )
                 then(
                   <td rowspan = '{ count( $i//tr ) + 1 }'>{ $c1 }</td>,
                   <td rowspan = '{ count( $i//tr ) + 1 }'>{ $i/@t/data()}</td>
                 )
                 else()
               }
               {
                 if( $c3 = 1 and $c4 = 1 )
                 then(
                   <td rowspan = '{ count( $ii//tr ) }'>{ $ii/@z/data() }</td>
                 )
                 else()
               }
               {
                 if( $c4 = 1 )
                 then(
                   <td rowspan = '{ count( $iii//tr ) }'>{ $iii/@p/data() }</td>
                 )
                 else()
               }
               <td>{ $tr/td[ last() - 1 ]/text() }</td>
               <td style = "text-align: center;">{ $tr/td[ last() ]/text() }</td>
             </tr>,
              if( $c2 = count( $i/ii) and $c3 = count( $ii/iii ) and $c4 = count( $iii/tr ) )
               then(
                 <tr style = "font-style: italic;">
                   <td colspan = '3'>Итого: </td>
                   <td style = "text-align: center;">{ sum( $i//td[2]/text() ) }</td>
                 </tr>
               )
               else()
           ),
             <tr style = "text-align: center; font-weight: bold;">
               <td colspan = '5'>Всего: </td>
               <td>{ sum( $data//tr/td[ last() ]/number() )}</td>
             </tr>
    }
  </table>
};

declare function local:datePipe( $date )  as xs:date {
  xs:date( replace( $date, '(\d{2}).(\d{2}).(\d{4})', '$3-$2-$1') )
};

  let $text:= 
    (
      'На основании приказа № 246-к от 24.09.2020г. среднее количество учащихся в классе – 26 человек',
      'На основании приказа № 246-к от 24.09.2020г. средняя наполняемость группы – 13 человек'
    )
  
  let $fromDate:= 
      if( $params?from )then(  $params?from )else( '2020-09-01' )
  let $toDate:= 
    if( $params?to )then( $params?to )else( '2020-09-10' )
    
  let $data := 
    .//table[1]/row
      [ cell[ @label = 'Дата' ]/local:datePipe( ./text() ) >= xs:date( $fromDate ) ]
      [ cell[ @label = 'Дата' ]/local:datePipe( ./text() ) <= xs:date( $toDate ) ]
  
  let $поКлассам := 
      $data[ cell[ @label = 'Предмет' ]/text() contains text ftnot { 'технология', 'английский', 'информатика', 'основы компьютерной' } ]
  let $поПодгруппам := 
    $data[ cell[ @label = 'Предмет' ]/text() contains text  { 'технология', 'английский', 'информатика', 'основы компьютерной' } ]  
    
  let $result := 
    <html>
      <header>
      </header>
      <body>
        <table style = "width : 50%">
          <tr>
            <td >
              <img width = '100px' src = "http://school26.ivedu.ru/images/stories/k_prazdnikam/gerb_school.gif"></img>
            </td>
            <td>
              <h1>Расчет количества замещенных уроков по МБОУ СШ № 26 г. Иваново</h1>
            </td>
          </tr>
        </table>
        <div>
          <form action="http://iro37.ru:9984/zapolnititul/api/v2.1/data/publication/900c0c39-3f5f-4d24-b328-0e4ecb5df3d8">
            <label>C <input type="date" name="from" value="{  $fromDate }"/></label>
            <label> по <input type="date" name="to" value="{ $toDate }"/></label>  
            <input type="submit"/>
          </form>
        </div>
        <div> 
          <h2>По классам</h2>
          <div>{ local:table( local:data( $поКлассам ), map{ 'text' : $text[ 1 ]} ) }</div>
        </div>
        <div>
          <h2>По подгруппам</h2>
          <div>{  local:table( local:data( $поПодгруппам ), map{ 'text' : $text[ 2 ]} ) }</div>
        </div>
      </body>
    </html>

return
  $result