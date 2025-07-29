create index samqa.pers_surname_i on
    samqa.person (
        last_name
    );


-- sqlcl_snapshot {"hash":"6730a0555ab67b9ba5632876efe3ed0b5a31bcc0","type":"INDEX","name":"PERS_SURNAME_I","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PERS_SURNAME_I</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PERSON</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>LAST_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}