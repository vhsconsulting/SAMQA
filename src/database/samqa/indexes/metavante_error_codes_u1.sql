create unique index samqa.metavante_error_codes_u1 on
    samqa.metavante_error_codes (
        error_id
    );


-- sqlcl_snapshot {"hash":"c381e1c53bcbde9886a5069285bcb8a3a074f3f9","type":"INDEX","name":"METAVANTE_ERROR_CODES_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_ERROR_CODES_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_ERROR_CODES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ERROR_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}