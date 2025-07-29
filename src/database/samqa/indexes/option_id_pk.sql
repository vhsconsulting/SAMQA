create unique index samqa.option_id_pk on
    samqa.hra_deductible_options (
        option_id
    );


-- sqlcl_snapshot {"hash":"bf5e44f930c34ce926776f93fe0d1a11e2df852b","type":"INDEX","name":"OPTION_ID_PK","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>OPTION_ID_PK</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>HRA_DEDUCTIBLE_OPTIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>OPTION_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}