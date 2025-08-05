create index samqa.medicare_pers_record_n1 on
    samqa.medicare_pers_record (
        pers_id
    );


-- sqlcl_snapshot {"hash":"c1b33a4e2df07e710583e71f5bd358242aca5889","type":"INDEX","name":"MEDICARE_PERS_RECORD_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MEDICARE_PERS_RECORD_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MEDICARE_PERS_RECORD</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PERS_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}