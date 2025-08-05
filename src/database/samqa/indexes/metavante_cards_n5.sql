create index samqa.metavante_cards_n5 on
    samqa.metavante_cards ( to_date(
        issue_date, 'YYYYMMDD') );


-- sqlcl_snapshot {"hash":"eae9f5b00cf90f86c67c70bfa9cf86f61fbf05e8","type":"INDEX","name":"METAVANTE_CARDS_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_CARDS_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_CARDS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TO_DATE(\"ISSUE_DATE\",'YYYYMMDD')</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}