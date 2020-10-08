let $таблица :=
  fetch:text(
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vQz49tPo-4g_F4D1NLkHT0dqCcalcXRVNUpn9cg3pKKurmJKNwQ8aqfpdeqVBmFSpoIkvJZHxERYGLa/pub?gid=0&amp;single=true&amp;output=csv'
  )
let $данные := csv:parse( $таблица, map{ 'header' : 'yes' } )
return
  <html>
    <head>
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous"/>
    </head>
    <header></header>
    <body>
      <div >
        {
          for $i in reverse( $данные//record )[ position() <= 10 ]
          return
             <div class="row border py-1 my-1 mx-0 bg-light">
                <div class="col-3">
                  <img src="{ $i/Фотография/text() }" class="rounded float-left img-fluid" alt="..."/>
                </div>
                <div class="col-9 bg-light">
                  <h3>{ $i/Название_новости/text() }</h3>
                  <div>{ $i/Дата/text() }</div>
                  <div>
                    { $i/Текст_новости/text() }
                  </div>
                  {
                    if( $i/Организатор/text() )
                    then(
                      <div>
                        <hr/>
                        <i>Организатор мероприятия: </i>
                        <i>{ $i/Организатор/text() }</i>
                      </div>
                    )
                    else()
                  }
                </div>
            </div>
        }
      </div>
    </body>
  </html>
  