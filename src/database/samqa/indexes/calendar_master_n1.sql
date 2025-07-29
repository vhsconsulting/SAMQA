create index samqa.calendar_master_n1 on
    samqa.calendar_master (
        calendar_type
    );


-- sqlcl_snapshot {"hash":"be3bfccfc386977342abab38b381c611b71608ea","type":"INDEX","name":"CALENDAR_MASTER_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CALENDAR_MASTER_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CALENDAR_MASTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CALENDAR_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}