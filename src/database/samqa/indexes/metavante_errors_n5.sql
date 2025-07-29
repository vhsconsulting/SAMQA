create index samqa.metavante_errors_n5 on
    samqa.metavante_errors ( trunc(last_update_date) );


-- sqlcl_snapshot {"hash":"f3dc65906e434f296a495230b86e303d8ff7a59a","type":"INDEX","name":"METAVANTE_ERRORS_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_ERRORS_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_ERRORS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(\"LAST_UPDATE_DATE\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}