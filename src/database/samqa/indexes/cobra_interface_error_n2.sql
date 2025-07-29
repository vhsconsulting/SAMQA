create index samqa.cobra_interface_error_n2 on
    samqa.cobra_interface_error (
        entity_id
    );


-- sqlcl_snapshot {"hash":"5770db4fffcc38766d8435d107aa423d553a46af","type":"INDEX","name":"COBRA_INTERFACE_ERROR_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>COBRA_INTERFACE_ERROR_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>COBRA_INTERFACE_ERROR</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTITY_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}